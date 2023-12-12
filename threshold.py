import time
from manta import Manta
m = Manta('fpgifa.yaml') # create manta python instance using yaml

for i in range(20):
    threshold = 50 + 5*i
    m.lab8_io_core.threshold_out.set(threshold) # set the threshold value
    time.sleep(0.5)
    print("set")