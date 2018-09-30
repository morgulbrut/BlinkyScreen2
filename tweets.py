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

    def on_data(self, data):
        for word in words:
            if word in data:
                i =  words.index(word)
                counts[i] = (5 + counts[i])%255
                pixels[i] = (0, counts[i], counts[i]) 
                client.put_pixels(pixels)
                  
        return True

    def on_error(self, status):
        pprint(status)
        return True
    
numLEDs = 512
client = opc.Client('10.3.141.1:7890')

if __name__ == '__main__':
    # wort = input("Bitte wählen Sie eine Zeichenkette, zu der Sie Daten sammeln möchten: ")
    # jumpback()
    
    counts = []

    with open('wordlist.txt') as wlst:
        words = wlst.read().split() 

    for i in range(len(words)):
        counts.append(0)
 
    for i in range(numLEDs):
        pixels = [ (0,0,0) ] * numLEDs

    # print("Daten werden gesammelt...") 
    auth = OAuthHandler(keys.consumer_key, keys.consumer_secret)
    auth.set_access_token(keys.access_token, keys.access_secret)
    api = tweepy.API(auth)

    twitter_stream = Stream(auth, MyListener())
    twitter_stream.filter(track=words)
 
                    



