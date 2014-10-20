
import unittest
from TestProfile import TestProfile
from TestResult import TestResult

class TestAll(unittest.TestCase):

    def setUp(self):
        pass

def suite():
    test_suite = unittest.TestSuite()
    test_suite.addTest(TestResult())
    test_suite.addTest(TestProfile())
    return test_suite

if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    test_suite = suite()
    runner.run(test_suite)