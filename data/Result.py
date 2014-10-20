from abc import abstractmethod, ABCMeta

class Result():
    """
    Class to represent a result
    """

    def __init__(self, jsonResult):
        self.jsonResult = jsonResult

    def validate(self):
        """
        Check if json is correctly formatted
        :return:
        """
        pass

    def getType(self):
        """
        Get the type of result
        :return:
        """
        pass

class ResultDataBase(object):
    """
    Abstract ResultData Class to deal with the different types of ResultData
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def getType(self):
        """Return Type of DataResult"""
        raise NotImplementedError()


class LocationData(ResultDataBase):
    """
    ResultData consisting on Location only
    """

    def getType(self):
        return "LocationData"