#####
## Libraries
#####

## Import openCV Commands only
from cv2 import VideoCapture, CAP_GSTREAMER, imencode

## Import other libraries
import Cython
from io import BytesIO
from json import dumps
from gc import collect
from time import time, sleep
from pathos.threading import ThreadPool
import threading
from random import choice

## Import jetson commands
from jtop import jtop

#####
## Configurations 1
#####

## Define if threads will be used
cdef bint useThreads = True

## Define Jetson Number
cdef str GB_jetsonNumber = "JETSON_3"

#####
## Functions
#####


###################################
## Define the cv2 commands to capture camera data
cpdef str gstreamer_pipeline(int sensor_id = 1, int capture_width = 4032, int capture_height = 3040, int display_width = 4032,
                       int display_height = 3040, int framerate = 30, int flip_method = 0):
    return (
        "nvarguscamerasrc sensor-id=%d exposuretimerange='1000000 1000000' !"
        "video/x-raw(memory:NVMM), width=(int)%d, height=(int)%d, framerate=(fraction)%d/1 ! "
        "nvvidconv flip-method=%d ! "
        "video/x-raw, width=(int)%d, height=(int)%d, format=(string)GRAY8 ! "
        "videoconvert ! "
        " appsink"
        % (
            sensor_id,
            capture_width,
            capture_height,
            framerate,
            flip_method,
            display_width,
            display_height,
        )
    )
###################################

###################################
## Image threatment
cpdef void imageThreat(LC_image, double LC_timestamp, double LC_startTime, str LC_camText):
    tempFile = BytesIO(imencode(".jpeg", LC_image)[1]).read().decode('latin-1')
    print('{} - {}'.format(LC_camText, time() - LC_startTime))
    return
###################################



##############
## MAIN PROGRAM
##############

###################################
cpdef void mainLoop():

    ## Create Thread pool for image threat
    imageThreat_threadPool_0 = ThreadPool(1)
    imageThreat_threadPool_1 = ThreadPool(18)

    ## Set framerate
    cdef int frameRate = 16

    ## Define Camera object
    cam0 = VideoCapture(gstreamer_pipeline(sensor_id = 0, capture_width = 1080, capture_height = 720, display_width = 1080,
                                          display_height = 720, framerate = frameRate, flip_method = 0), CAP_GSTREAMER)
    sleep(1)
    cam1 = VideoCapture(gstreamer_pipeline(sensor_id = 1, capture_width = 4032, capture_height = 3040, display_width = 4032,
                                           display_height = 3040, framerate = frameRate, flip_method = 0), CAP_GSTREAMER)
    sleep(1)

    ## Define Cam Text
    #cdef char LC_sensorId = '0'
    cdef str camText0 = "CAM_0__JETSON_3"

    #cdef char LC_sensorId1 = '1'
    cdef str camText1 = "CAM_1__JETSON_3"

    ## Init variables
    cdef int clearControl_counter = 1
    cdef float averageFrameRate = 30

    ## Time Rate
    cdef double timeRate = 1/frameRate

    cdef double startTime
    cdef double timeDiff
    cdef double endTime
    cdef double currentFrameRate

    ## Infinite Loop
    while True:
        ## Get start Time
        startTime = time()

        ## Send to thread or process normal
        if useThreads:
            ## Send CAM0
            imageThreat_threadPool_1.apipe(imageThreat, cam0.read()[1].copy(), time(), startTime, camText0)
        else:
            ## Send CAM0
            imageThreat(cam0.read()[1], time(), startTime, camText0)

        ## Send to thread or process normal
        if useThreads:
            ## Send CAM1
            imageThreat_threadPool_1.apipe(imageThreat, cam1.read()[1].copy(), time(), startTime, camText1)

        else:
            ## Send CAM1
            imageThreat(cam1.read()[1], time(), startTime, camText1)

        ## Clear memory after 30 frames
        #if clearControl_counter%10 == 0:
        #    collect()
        #    clearControl_counter = 1
        #    print(f"COLLECT")
        #else:
        #    clearControl_counter += 1

        ## Wait for framerate
        timeDiff = timeRate - (time()-startTime)
        if timeDiff > 0 :
            sleep(timeDiff)

        ## Get frameRate
        if not(useThreads):
            endTime = time()
            currentFrameRate = 1/(endTime-startTime)
            averageFrameRate = (currentFrameRate + averageFrameRate)/2
            print("Frame Rate: {} -- Average Rate: {} -- Last frame time in seconds: {}".format(currentFrameRate, averageFrameRate, endTime - startTime))
###################################
