import unittest
import json
from data.Profile import Profile

class TestProfile(unittest.TestCase):
    """
    Testing the Profile class
    """

    def setUp(self):
        resultList = ['profile_test.json']
        jsonProfileList = []
        for filename in resultList:
            with open('../testfiles/'+filename, 'r') as p:
                jsonProfile = json.load(p)
                jsonProfileList.append(jsonProfile)
        self.jsonProfileList = jsonProfileList

    def test_profile(self):
        # not a proper testfiles
        for jsonProfile in self.jsonProfileList:
            profile = Profile(jsonProfile)
            profile.validateProfile()
            profile.checkStatus()

if __name__ == '__main__':
    unittest.main()