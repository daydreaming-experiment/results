# -*- coding: utf-8 -*-

import json
import csv
from datetime import datetime
import os
import numpy as np

def get_by_field(l, name, value):
    values = [item.get(name) for item in l]
    c = values.count(value)
    if c == 0:
        raise ValueError("'{}' == {} not found".format(name, value))
    if c > 1:
        raise ValueError("'{}' == {} found {} times".format(name, value, c))
    return l[values.index(value)]


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



def SODAS_score(v):
    return np.mean(v)

def MAAS_score(v):
    return 100.-np.mean(v)

def Rumination_score(v_RR):
    v = [v_ if i+1 not in [6, 9, 10, 13, 14, 17, 20, 24] else 100.-v_\
         for i,v_ in enumerate(v_RR)  ]
    return np.mean(v[:13])

def Reflection_score(v_RR):
    v = [v_ if i+1 not in [6, 9, 10, 13, 14, 17, 20, 24] else 100.-v_\
         for i,v_ in enumerate(v_RR)  ]
    return np.mean(v[14:])


def do_results_from_json(good_profiles, result_json_file, csv_output='results-latest.csv'):

    good_profile_ids = [p['id'] for p in good_profiles]

    with open(result_json_file, 'r') as file_results:
        results = json.load(file_results)['results']


    if not os.path.exists(csv_output):
        open(csv_output, 'w')
        isfirst = True
    else:
        isfirst = False

    with open(csv_output, 'a') as csv_results:
        writer = csv.writer(csv_results, delimiter='\t')

        root_fields = ['id', 'profile_id']
        common_fields = ['type', 'name', 'status', 'systemDate', 'ntpDate']

        morning_fields = ['morning.selfInitiated',
                          'morning.sleep',
                          'morning.dreams',
                          'morning.valence']

        evening_fields = ['evening.selfInitiated',
                          'evening.activity.1',
                          'evening.activity.2',
                          'evening.activity.3',
                          'evening.happy',
                          'evening.mindful']


        MAAS_fields = ['MAAS'+str(i) for i in range(1,16)]+['MAAS_score']
        RR_fields = ['RR'+str(i) for i in range(1,25)]+['Rumination_score','Reflection_score']
        SODAS_fields = ['SODAS'+str(i) for i in range(1,36)]+['SODAS_score']



        begin_end_fields = MAAS_fields+RR_fields+SODAS_fields


        probe_fields = ['probe.selfInitiated',
                        'probe.thought.focus.focusedDoing',
                        'probe.thought.focus.awareWandering',
                        'probe.thought.surround', 'probe.thought.words',
                        'probe.thought.visual', 'probe.thought.auditory',
                        'probe.context.location.1', 'probe.context.location.2',
                        'probe.context.location.3',
                        'probe.context.activity.1', 'probe.context.activity.2',
                        'probe.context.activity.3',
                        'probe.context.noise.1',
                        'probe.context.noise.2',
                        'probe.context.noise.3',
                        'probe.context.interaction',
                        'probe.context.people']

        if isfirst:
            writer.writerow(root_fields + common_fields + morning_fields +
                        evening_fields +  probe_fields  + begin_end_fields + begin_end_fields)

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
            status = rdata['status']
            common_values.append(tipe)
            common_values.append(name)
            common_values.append(status)

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

            if status == 'missedOrDismissedOrIncomplete':
                writer.writerow(root_values + common_values + morning_values +
                                evening_values + probe_values+
                                begin_end_values +
                                begin_end_values )
                continue

            # ---------------------------------------------

            if tipe == 'morningQuestionnaire':
                morning_values.append(rdata.get('selfInitiated', ''))

                pMorningUnique= rdata['pageGroups'][0]['pages'][0]

                sleepAnswer = get_by_field(
                    pMorningUnique['questions'], 'questionName',
                    'morning.sleep')['answer']['sliders']
                dreamsAnswer = get_by_field(
                    pMorningUnique['questions'], 'questionName',
                    'morning.dreams')['answer']['sliders']
                valenceAnswer = get_by_field(
                    pMorningUnique['questions'], 'questionName',
                    'morning.valence')['answer']['sliders']

                morning_values.append(
                    dreamsAnswer['How vivid were your dreams?'])
                morning_values.append(
                    valenceAnswer['How were your dreams?'])
                morning_values.append(
                    sleepAnswer['How long have you slept?'])


            else:
                morning_values = [''] * len(morning_fields)

            # ---------------------------------------------

            if tipe == 'eveningQuestionnaire':
                evening_values.append(rdata.get('selfInitiated', ''))


                pagesEvening = rdata['pageGroups'][0]['pages']

                # --  'evening.activity.manySliders'
                for pageEvening in pagesEvening:
                    if pageEvening["name"] == "usualActivities":
                        questions = pageEvening['questions']
                        for question in questions:
                            answer = question["answer"]["sliders"]
                            for i, c in enumerate(answer.keys()[:3]):
                                evening_values.append(c)
                            for j in range(2 - i):
                                evening_values.append('')


                for pageEvening in pagesEvening:
                    if pageEvening["name"] == "mindfulhappy":
                        questions = pageEvening['questions']

                # --  'evening.happy'
                        for question in questions:
                            #print question
                            if question["questionName"] == 'evening.happy':
                                answer = question["answer"]["sliders"]
                                for key in answer.keys():
                                    evening_values.append(answer[key])
                                    #print key, answer[key]

                # --  'evening.mindful'
                        for question in questions:
                            if question["questionName"] == 'evening.mindful':
                                answer = question["answer"]["sliders"]
                                for key in answer.keys():
                                    evening_values.append(answer[key])
                                    #print key, answer[key]


            else:
                evening_values = [''] * len(evening_fields)

            # ---------------------------------------------

            if tipe == 'beginQuestionnaire':
                begin_values = []
                names = ['MAAS','RR','SODAS']
                fields = [MAAS_fields,RR_fields,SODAS_fields]
                for name, field in zip(names,fields):
                    if rdata['name'] == 'begin'+name:
                        pages = rdata['pageGroups'][0]['pages']
                        values = []
                        for page in pages:
                            questions = page['questions']
                            for question in questions:
                                answer = question['answer']['sliders']
                                q_phrase = answer.keys()[0]
                                values.append(answer[q_phrase])
                        begin_values += values
                        # appending score
                        if name == 'SODAS':
                            begin_values.append(SODAS_score(values))
                        elif name == 'RR':
                            begin_values+=[Rumination_score(values),Reflection_score(values)]
                        elif name == 'MAAS':
                            begin_values.append(MAAS_score(values))

                    else:
                        begin_values += [''] * len(field)

            else:
                begin_values = [''] * len(begin_end_fields)


            if tipe == 'endQuestionnaire':
                end_values = []
                names = ['MAAS','RR','SODAS']
                fields = [MAAS_fields,RR_fields,SODAS_fields]
                for name, field in zip(names,fields):
                    if rdata['name'] == 'end'+name:
                        pages = rdata['pageGroups'][0]['pages']
                        values = []
                        for page in pages:
                            questions = page['questions']
                            for question in questions:
                                answer = question['answer']['sliders']
                                q_phrase = answer.keys()[0]
                                values.append(answer[q_phrase])
                        end_values += values
                                                # appending score
                        if name == 'SODAS':
                            end_values.append(SODAS_score(values))
                        elif name == 'RR':
                            end_values+=[Rumination_score(values),Reflection_score(values)]
                        elif name == 'MAAS':
                            end_values.append(MAAS_score(values))

                    else:
                        end_values += [''] * len(field)

            else:
                end_values = [''] * len(begin_end_fields)




                #q_name = rdata['pageGroups'][0]['name']

                #for q_type in ['MAAS','RR','SODAS']:
                #    pThought = get_by_field(rdata['pageGroups'], 'name',
                #                        'thought')['pages'][0]

                #    if q_name == q_type:
                #        pages = rdata['pageGroups'][0]['pages']
                #        for page in pages:
                #            questions = page['questions']
                #            for question in questions:
                #                answer = question['answer']['sliders']
                #                q_phrase = answer.keys()[0]
                #                begin_values.append(answer[q_phrase])


            #-------------------------------------------------------

            if tipe == 'probe':
                probe_values.append(rdata.get('selfInitiated', ''))

                # Thought answers
                pThought = get_by_field(rdata['pageGroups'], 'name',
                                        'thought')['pages'][0]
                focusAnswers = get_by_field(
                    pThought['questions'], 'questionName',
                    'probe.thought.focus')['answer']['sliders']

                s = 'How focused were you on what you were doing?'
                probe_values.append( focusAnswers[s] if s in focusAnswers else '')
                s = 'How aware were you of your mind wandering?'
                probe_values.append( focusAnswers[s] if s in focusAnswers else '')



                probe_values.append(
                    get_by_field(pThought['questions'], 'questionName',
                                 'probe.thought.surround')\
                    ['answer']['sliders'].values()[0])
                probe_values.append(
                    get_by_field(pThought['questions'], 'questionName',
                                 'probe.thought.words')\
                    ['answer']['sliders'].values()[0])
                probe_values.append(
                    get_by_field(pThought['questions'], 'questionName',
                                 'probe.thought.visual')\
                    ['answer']['sliders'].values()[0])
                probe_values.append(
                    get_by_field(pThought['questions'], 'questionName',
                                 'probe.thought.auditory')\
                    ['answer']['sliders'].values()[0])

                # Context answers
                pgContext = get_by_field(rdata['pageGroups'], 'name',
                                         'context')
                pLocation = get_by_field(pgContext['pages'], 'name',
                                         'location')
                for i, c in enumerate(
                        pLocation['questions'][0]['answer']['choices'][:3]):
                    probe_values.append(c)
                for j in range(2 - i):
                    probe_values.append('')

                pActivity = get_by_field(pgContext['pages'], 'name',
                                         'activity')
                for i, c in enumerate(
                        pActivity['questions'][0]['answer']['choices'][:3]):
                    probe_values.append(c)
                for j in range(2 - i):
                    probe_values.append('')

                pNoise = get_by_field(pgContext['pages'], 'name',
                                      'noise')

                answer = get_by_field(pNoise['questions'], 'questionName', 'probe.noise')['answer']
                if 'choices' in answer:
                    for i, c in enumerate(answer['choices'][:3]):
                        probe_values.append(c)
                    for j in range(2 - i):
                        probe_values.append('')
                else:
                    probe_values + ['']*3

                probe_values.append(
                    get_by_field(pNoise['questions'], 'questionName',
                                 'probe.interaction')\
                    ['answer']['sliders'].values()[0])
                probe_values.append(
                    get_by_field(pNoise['questions'], 'questionName',
                                 'probe.people')\
                    ['answer']['sliders'].values()[0])
            else:
                probe_values = [''] * len(probe_fields)

            writer.writerow(root_values + common_values + morning_values +
                            evening_values  + probe_values + begin_values + end_values)


def do_results(good_profiles, result_json_files=['results_latest.json'], csv_output='results-latest.csv'):
    assert isinstance(result_json_files, list)

    if os.path.exists(csv_output):
        os.remove(csv_output)

    for result_json_file in result_json_files:
        do_results_from_json(good_profiles, result_json_file, csv_output=csv_output)


def getQuestionNames(prefixes, grammar):

    assert grammar in ['grammar-v3.1'], 'invalid grammar'
    if not isinstance(prefixes, list):
        prefixes = [prefixes]

    names = []
    path = '../parameters/'+grammar+'/production.json'
    print "opening:"+path
    with open('../parameters/'+grammar+'/production.json', 'r') as p:
        questions = json.load(p)['questions']

    for prefix in prefixes:
        assert prefix in ['morning', 'evening', 'probe', 'MAAS', 'RR', 'SODAS'], 'invalid prefix {0} for question'.format(prefix)

        for question in questions:
            prefix_ = question['name'].split('.')[0]
            if prefix in prefix_:
                names.append(question['name'])
    return names


def merge_results_json(json_file_list):
    assert isinstance(json_file_list,list)

    for file in json_file_list:
        with open(json_file_list, 'r') as file_results:
            results = json.load(file_results)['results']



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


    result_json_files = ['results-'+str(i)+'.json' for i in range(9)]
    do_results(good_profiles,result_json_files=result_json_files)
    print "OK"
    print
    print "All done!"

    for type in ['morning', 'evening', 'probe', ['MAAS', 'RR', 'SODAS']]:
        print getQuestionNames(type ,'grammar-v3.1')