#!/usr/bin/env python

import Adafruit_DHT  
import json  
import paho.mqtt.publish as mqtt_pub  
import time

dht_pin = 4  

dht = Adafruit_DHT.AM2302

broker = 'bunker.imagilan'  
topic = 'passage/am2302'  
interval = 10

while True:  
    h, t = Adafruit_DHT.read_retry(dht, dht_pin)
    obj = {
        'timestamp': int(time.time()),
        'humidity': int(h),
        'temperature': int(t)
        }
    txt = json.dumps(obj)
    print txt
    mqtt_pub.single(topic, txt, hostname=broker)
    time.sleep(interval)
