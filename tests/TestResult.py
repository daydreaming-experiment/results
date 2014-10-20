import unittest
import json
from data.Result import Result

class TestResult(unittest.TestCase):
    """
    Testing the Result class
    """

    def setUp(self):
        resultList = ['result_test_mq.json', 'result_test_location.json']
        jsonResultList = []
        for filename in resultList:
            with open('../testfiles/'+filename, 'r') as r:
                jsonResult = json.load(r)
                jsonResultList.append(jsonResult)
        self.jsonResultList = jsonResultList

    def test_result(self):
        # not a proper testfiles
        for jsonResult in self.jsonResultList:
            result = Result(jsonResult)
            result.validate()

if __name__ == '__main__':
    unittest.main()