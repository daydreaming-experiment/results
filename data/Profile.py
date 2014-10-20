class Profile():
    """
    Class to represent a subject's profile information
    """

    def __init__(self, jsonProfile):
        self.jsonProfile = jsonProfile
        self.profileData = ProfileData(jsonProfile["profile_data"])


    def validateProfile(self):
        """
        Check if Profile is correctly formatted
        :return:
        """
        requiredFields = ["device_id", "exp_id", "id", "n_results", "profile_data", "vk_pem"]
        #['age', 'appVersionCode', 'appVersionName', 'education', 'gender', 'mode', 'parametersVersion']

        for field in requiredFields:
            if not field in self.jsonProfile:
                raise NotImplementedError("missing field: {}".format(field))
        print "profile is ok"
        return True

    def checkStatus(self):
        """
        Check if Profile corresponds to expectations (to be externalized)
        :return:
        """

        # arbitrary conditions
        minAppVersionCode = 50
        parametersVersion = '3.1-production-2'
        min_n_results = 10

        if self.jsonProfile['profile_data'].get('appVersionCode') >= minAppVersionCode\
        and '+' not in self.jsonProfile['profile_data'].get('appVersionName')\
        and self.jsonProfile['n_results'] >= min_n_results\
        and self.jsonProfile['profile_data'].get('parametersVersion') == parametersVersion:
            print "profile is correct"
            return True
        else:
            print "bad profile"
            return False


class ProfileData():
    """
    Class to represent a subject's profileData information
    """

    def __init__(self, profileData):
        self.profileData = profileData
        self.validateProfileData()

    def validateProfileData(self):
        """
        Check if ProfileData is correctly formatted
        :return:
        """
        print "TODO: profile_data is correct"
        pass


