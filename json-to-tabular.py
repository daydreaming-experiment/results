# -*- coding: utf-8 -*-

import json
import csv
from datetime import datetime


def do_profiles():
    with open('profiles-latest.json', 'r') as file_profiles:
        profiles = json.load(file_profiles)['profiles']

    good_profiles = []
    with open('profiles-latest.csv', 'wb') as csv_profiles:
        writer = csv.writer(csv_profiles, delimiter='\t')

        root_fields = ['id', 'n_results', 'exp_id', 'device_id']
        data_fields = ['age', 'gender', 'education', 'motherTongue',
                       'parametersVersion', 'appVersionName',
                       'appVersionCode', 'mode']
        writer.writerow(root_fields + data_fields)
        for p in profiles:
            if 'parametersVersion' not in p['profile_data']:
                continue
            pVersion = p['profile_data']['parametersVersion']
            pVersionParts = pVersion.split('-')
            if pVersionParts[0] < '3.1':
                continue
            if pVersionParts[1] != 'production':
                continue
            if pVersionParts[2] < '1':
                continue
            good_profiles.append(p)

            values = []
            for rf in root_fields:
                values.append(p.get(rf, ''))
            for df in data_fields:
                dv = p['profile_data'].get(df, '')
                if isinstance(dv, unicode):
                    dv = dv.encode('utf8')
                values.append(dv)
            writer.writerow(values)

    return good_profiles


def do_results(good_profiles):
    good_profile_ids = [p['id'] for p in good_profiles]

    with open('results-latest.json', 'r') as file_results:
        results = json.load(file_results)['results']

    with open('results-latest.csv', 'wb') as csv_results:
        writer = csv.writer(csv_results, delimiter='\t')

        root_fields = ['id', 'profile_id']
        common_fields = ['type', 'name', 'status', 'systemDate', 'ntpDate']
        morning_fields = []
        evening_fields = []
        begin_end_fields = []
        probe_fields = ['probe.selfInitiated',
                        'probe.thought.focus.absorbedDoing',
                        'probe.thought.focus.focusedDoing',
                        'probe.thought.focus.awareWandering',
                        'probe.thought.surround', 'probe.thought.words',
                        'probe.thought.visual', 'probe.thought.auditory',
                        'probe.context.location.1', 'probe.context.location.2',
                        'probe.context.activity.1', 'probe.context.activity.2',
                        'probe.context.activity.3',
                        'probe.context.noise', 'probe.context.interaction',
                        'probe.context.people']

        writer.writerow(root_fields + common_fields + morning_fields +
                        evening_fields + begin_end_fields + probe_fields)

        for r in results:
            if r['profile_id'] not in good_profile_ids:
                continue

            rdata = r['result_data']

            # Skip locations
            if 'locationLatitude' in rdata:
                continue

            # Init values
            root_values = []
            common_values = []
            morning_values = []
            evening_values = []
            begin_end_values = []
            probe_values = []

            # Get root and common values
            root_values.append(r['id'])
            root_values.append(r['profile_id'])
            tipe = rdata['type']
            name = rdata['name']
            common_values.append(tipe)
            common_values.append(name)
            common_values.append(rdata['status'])

            systemTimestamp = \
                rdata['pageGroups'][0]['pages'][0]['systemTimestamp']
            if systemTimestamp != -1:
                # Add systme date
                common_values.append(datetime.utcfromtimestamp(
                    systemTimestamp / 1000.0).strftime(r'%Y-%m-%d'))
            else:
                common_values.append('')

            ntpTimestamp = rdata['pageGroups'][0]['pages'][0]['ntpTimestamp']
            if ntpTimestamp != -1:
                # Add ntp date
                common_values.append(datetime.utcfromtimestamp(
                    ntpTimestamp / 1000.0).strftime(r'%Y-%m-%d'))
            else:
                common_values.append('')

            if tipe == 'morningQuestionnaire':
                pass
            else:
                morning_values = [''] * len(morning_fields)

            if tipe == 'eveningQuestionnaire':
                pass
            else:
                evening_values = [''] * len(evening_fields)

            if tipe == 'beginQuestionnaire' or tipe == 'endQuestionnaire':
                pass
            else:
                begin_end_values = [''] * len(begin_end_fields)

            if tipe == 'probe':
                pass
            else:
                probe_values = [''] * len(probe_fields)

            writer.writerow(root_values + common_values + morning_values +
                            evening_values + begin_end_values + probe_values)


if __name__ == '__main__':
    msg = "Converting profile and result data to tabular csv"
    print '-' * len(msg)
    print msg
    print '-' * len(msg)

    print
    print ("Converting profiles (only with 'parametersVersion' "
           ">= 3.1-production-1)..."),
    good_profiles = do_profiles()
    print "OK"
    print "Converting results (only for profiles kept at previous step)...",
    do_results(good_profiles)
    print "OK"
    print
    print "All done!"
