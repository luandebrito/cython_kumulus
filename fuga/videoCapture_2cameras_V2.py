#####
## Libraries
#####

## Import openCV Commands only
from cv2 import VideoCapture, CAP_GSTREAMER, imencode

## Import other libraries
from LIBvideoCapture_2cameras_V2 import *

## Import jetson commands
from jtop import jtop

###################################
if __name__ == '__main__':

    ## Setup jetson
    with jtop() as jetson:
        jetson.jetson_clocks = True
        jetson.fan.speed = 100
    sleep(20)

    ## Call main Loop
    # mainLoop = threading.Thread(name = 'daemon', target = mainLoop)
    # mainLoop.setDaemon(True)
    # mainLoop.start()

    ## Call main Loop
    mainLoop()