#!/usr/bin/env python

import Adafruit_DHT  
import json  
import paho.mqtt.publish as mqtt_pub  
import time

dht_pin  = 4  
dht      = Adafruit_DHT.AM2302
broker   = 'mqtt.imagilan'
topic    = 'homie/pi02'
interval = 10

while True:  
    h, t = Adafruit_DHT.read_retry(dht, dht_pin)
    mqtt_pub.single(topic + '/temperature', int(t), hostname=broker)
    mqtt_pub.single(topic + '/humidity',    int(h), hostname=broker)
    time.sleep(interval)
