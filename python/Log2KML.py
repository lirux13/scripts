#!/usr/bin/python3
# -*- coding: utf-8 -*-

# 从log读取GGA和RMC生成KML文件

import re
import sys

fileOut = "gga_out.txt"
fileKML = '2.kml'

#--- UTCTime ---
#125938.99
#
#--- Latitude ---
#22.5526294333
#
#--- Longitude ---
#113.9114495
#
#--- FixQuality ---
#5
#
#--- NumberOfSatellites ---
#14
#
#--- HDOP ---
#0.8
#
#--- Altitude ---
#['10.733', 'M']
#
#--- HeightOfGeoidAboveWGS84Ellipsoid ---
#['0.0', 'M']
def parseGGA(str):
	gga = str.split(',')

	#if len(gga) < 15 or gga[2] == '' or gga[4] == '':
	if len(gga) < 15 :
		return ("", "", "", "", "", "", "", "")

	#--- UTCTime ---
	UTCTime = gga[1]
	#--- Latitude ---
	if gga[2] == '':
		Latitude = ''
	else:
		lat = float(gga[2])
		lat = int(lat/100) + ((lat - int(lat/100)*100) / 60)
		if gga[3] == 's':
			lat = -lat
		Latitude = '%f' % (lat)
	#--- Longitude ---
	if gga[4] == '':
		Longitude = ''
	else :
		lon = float(gga[4])
		lon = int(lon/100) + ((lon - int(lon/100)*100) / 60)
		if gga[5] == 'W':
			lon = -lon
		Longitude = '%f' % (lon)
	#--- FixQuality ---
	FixQuality = gga[6]
	#--- NumberOfSatellites ---
	if gga[7] == '':
		NumberOfSatellites = ''
	else :
		NumberOfSatellites = '%d' % (int(gga[7]))
	#--- HDOP ---
	HDOP = gga[8]
	#--- Altitude ---
	#Altitude=["\'"+gga[9]+"\'", "\'"+gga[10]+"\'"]
	#Altitude = [gga[9], gga[10]]
	Altitude = "['%s', '%s']" % (gga[9], gga[10])
	#--- HeightOfGeoidAboveWGS84Ellipsoid ---
	#Height = [gga[11], gga[12]]
	Height = "['%s', '%s']" % (gga[11], gga[12])

	return (UTCTime, Latitude, Longitude, FixQuality, NumberOfSatellites, HDOP, Altitude, Height)

def parseRMC(str):
	#2019-01-08T10:22:00.882000Z
	dtStr = ""
	rmc = str.split(',')
	try :
		time = int(float(rmc[1]))
		date = int(rmc[9])
		DD = date / 10000
		MM = date / 100 % 100
		YYYY = date % 100 + 2000
		hh = time / 10000
		mm = time / 100 % 100
		ss = time % 100
		dtStr = '%d-%02d-%02dT%02d:%02d:%02d' % (YYYY, MM, DD, hh, mm, ss)
	except:
		print("RMC error:", str)
	
	return dtStr

KML_HEAD = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.1" >
  <Document>
    <name>
    %s
    </name>
    <Style id="Pt_STYLE">
      <IconStyle>
        <color> FF78FA00 </color>
        <scale> 0.8 </scale>
        <Icon> <href> http://maps.google.com/mapfiles/kml/shapes//placemark_circle.png </href></Icon>
      </IconStyle>
      <LabelStyle>
        <color> FF78FA00 </color>
      </LabelStyle>
    </Style>
    <Style id="Pt_STYLE_line">
      <IconStyle>
        <color> FF78FA00 </color>
        <scale> 0.8 </scale>
        <Icon> <href> http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png </href></Icon>
      </IconStyle>
      <LineStyle>
        <color> FF78FA00 </color>
        <width> 4 </width>
      </LineStyle>
    </Style>
    <Folder>
    <name>fix points</name>
	'''

KML_TAIL = '''    </Folder>
  </Document>
</kml>'''

KML_FORMAT = '''    <Placemark><name></name><description><![CDATA[PN%d--- UTCTime ---
%s

--- Latitude ---
%s

--- Longitude ---
%s

--- FixQuality ---
%s

--- NumberOfSatellites ---
%s

--- HDOP ---
%s

--- Altitude ---
%s

--- HeightOfGeoidAboveWGS84Ellipsoid ---
%s

]]></description>
<TimeStamp><when>%s.882000Z</when></TimeStamp>
<LookAt></LookAt>
<styleUrl>#Pt_STYLE</styleUrl>
<MultiGeometry><Point><coordinates>%s,%s</coordinates></Point>
<LineString><coordinates></coordinates></LineString>
</MultiGeometry>
</Placemark>
'''


if __name__ == '__main__':
	if len(sys.argv) < 2:
		print('命令格式: \n\tpython', sys.argv[0], '<log文件名> <KML文件名>')
		exit()

	fielName = sys.argv[1]

	if len(sys.argv) >= 3:
		fileKML = sys.argv[2] + ".kml"

	textLines = []
	print(fielName, "\nReading...\n")
	dataBytes = bytes()
	fileObject = open(fielName, 'rb')
	try:
		dataBytes = fileObject.read()
	finally:
		fileObject.close()

	byteBuffer = bytearray()

	outObject = open(fileOut, 'w')
	kmlObject = open(fileKML, 'w')

	textBuffer = KML_HEAD % (fileKML)
	kmlObject.write(textBuffer)
	(UTCTime, Latitude, Longitude, FixQuality, NumberOfSatellites, HDOP, Altitude, Height) = ("", "", "", "", "", "", "", "")
	i = 1
	for b in dataBytes:
		if b == 0x0A :
			byteBuffer.append(b)
			textBuffer = str(byteBuffer, encoding = 'utf-8')

			if not ('fusion' in textBuffer) :
				byteBuffer.clear()
				continue

			if ('GNGGA' in textBuffer) :
				try :
					idx = textBuffer.find('$GNGGA')
					textBuffer = textBuffer[idx:].strip()
					(UTCTime, Latitude, Longitude, FixQuality, NumberOfSatellites, HDOP, Altitude, Height) = parseGGA(textBuffer)
					#array = parseGGA(textBuffer)
					if UTCTime != '' :
						outObject.write(textBuffer+"\r\n")
				finally :
					byteBuffer.clear()
			elif ('RMC' in textBuffer) :
				try :
					dataTime = parseRMC(textBuffer)
					if Latitude != '' and Latitude != '' and dataTime != '':
						kmlObject.write(KML_FORMAT % (i, UTCTime, Latitude, Longitude, FixQuality, NumberOfSatellites, HDOP, Altitude, Height, dataTime, Longitude, Latitude))
						i = i + 1
				finally :
					byteBuffer.clear()
			else :
				byteBuffer.clear()
		elif b <= 0x95 :
			byteBuffer.append(b)

	kmlObject.write(KML_TAIL)
	outObject.close()
	kmlObject.close()

	#KML_appendHead()

