import time
from manta import Manta
m = Manta('fpgifa.yaml') # create manta python instance using yaml

threshold = 32
m.lab8_io_core.threshold_out.set(threshold) # set the threshold value
print("set")