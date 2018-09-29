#!/usr/bin/env python

import opc, time
import os
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import time
import string
import sys
import keys
import json
from pprint import pprint

class MyListener(StreamListener):

    def __init__(self):
        self.trump = 0
        self.maga = 0

    def on_data(self, data):
        if 'trump' in data.lower():
            self.trump +=1
        if 'maga' in data.lower():
            self.maga +=1

        print('trump: {}'.format(self.trump))
        print('maga: {}'.format(self.maga))
        # try:
        #     filepath = '/home/tillo/Mining-Data/miner-'+ wort +'.json'
        #     with open(filepath, 'a') as f:
        #         f.write(data)
        #         f.write("\n") 
        #         print(data)
        #         return True
        # except BaseException as e:
        #     print("Error on_data: %s" % str(e))
        #     time.sleep(5)
        return True

    def on_error(self, status):
        pprint(status)
        return True
    
def jumpback():
    sys.stdout.write("\033[F")
    sys.stdout.write("\033[K")

# numLEDs = 512
# client = opc.Client('10.3.141.1:7890')


def get_hashtags():
    pass

if __name__ == '__main__':
    # wort = input("Bitte wählen Sie eine Zeichenkette, zu der Sie Daten sammeln möchten: ")
    # jumpback()
                 
    # print("Daten werden gesammelt...") 
    auth = OAuthHandler(keys.consumer_key, keys.consumer_secret)
    auth.set_access_token(keys.access_token, keys.access_secret)
    api = tweepy.API(auth)

    twitter_stream = Stream(auth, MyListener())
    twitter_stream.filter(track=['Trump','Maga'])


# for i in range(numLEDs):
#   pixels = [ (0,0,0) ] * numLEDs
#   pixels[i] = (0, 255, 255)
#   client.put_pixels(pixels)
#   time.sleep(0.01)
