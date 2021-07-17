#!/usr/bin/env python3

import sys
import argparse
import zipfile
import json
from base64 import b64decode
from pathlib import Path

'''
{
	"id": "88065",
	"version": "1",
	"bookname": "0JbQuNC30L3QtdGB0L/QvtGB0L7QsdC90L7RgdGC0Ywg0YfQtdC70L7QstC10LrQsCDQuCDRgdC10LzRjNC4",
	"pubhouse": "0JjQt9C00LDRgtC10LvRjNGB0YLQstC+IMKr0JjQvdGB0YLQuNGC0YPRgiDQv9GB0LjRhdC+0LvQvtCz0LjQuCDQoNCQ0J3Cuw==",
	"author": "0JzQsNGF0L3QsNGHINCQLtCSLg==",
	"year": "MjAxNg==",
	"isbn": "OTc4LTUtOTI3MC0wMzIxLTE=",
	"okso": "",
	"created": "1569616201",
	"unpub_date": "1451606400",
	"unpub_hash": "8edfee2ee77ba00d2a11341015d699e5",
	"bytearray": "..."
}
'''


def create_parser():
	parser = argparse.ArgumentParser(description='Decrypt .bff file to .swf format')
	parser.add_argument('bff_file')
	parser.add_argument('-o', '--swf_file')
	parser.add_argument('-t', '--tmp_dir', default='tmp')
	return parser


def b64(encoded_str):
	return b64decode(encoded_str).decode("utf-8")


def unzip_BFF(bff_file, tmp_folder):
	try:
		with zipfile.ZipFile(bff_file, 'r') as zip_ref:
			listOfiles = zip_ref.namelist()
			if len(listOfiles) == 1:
				fileName = Path(listOfiles[0])
				if fileName.suffix == '.ubff':
					zip_ref.extractall(tmp_folder)
					return tmp_folder / fileName
	except:
		pass

	raise Exception(f'File "{bff_file}" is not valid BFF file')


def open_UBFF(ubff_file):
	try:
		with open(ubff_file) as file:
			data = json.load(file)
			if data['version'] == '1':
				print('Id:', data['id'])
				print('BookName:', b64(data['bookname']))
				print('PubHouse:', b64(data['pubhouse']))
				print('Author:', b64(data['author']))
				print('Year:', b64(data['year']))
				print()
				return data['bytearray']
	except:
		pass

	raise Exception("Version of UBFF file is not supported")


def decrypt_data(ubff_data):
	try:
		result = ''
		idx = 1
		flag = ord(ubff_data[0])
		
		if (flag % 2 == 1): flag -= 1
		
		while (idx < flag):
			result += ubff_data[idx + 1] + ubff_data[idx]
			idx += 2
			
		result += ubff_data[flag + 2:]
		result = b64decode(result)
		
		if result[:3] == b'CWS':
			return result
	except:
		pass

	raise Exception("Failed to convert UBFF bytearray to SWF format")


def save_SWF(swf_data, swf_file):
	try:
		filepath = Path(swf_file)
		filepath.parent.mkdir(parents=True, exist_ok=True)

		with open(filepath, 'wb') as file:
			file.write(swf_data)
			return True
	except:
		pass
		
	raise Exception(f'Failed to save SWF "{swf_file}" file')


if __name__ == '__main__':
	parser = create_parser()
	ns = parser.parse_args()
	created = False

	print("START SCRIPT")
	print()
	try:
		ubff_file = unzip_BFF(ns.bff_file, ns.tmp_dir)
		ubff_data = open_UBFF(ubff_file)
		if ns.swf_file is not None:
			data = decrypt_data(ubff_data)
			created = save_SWF(data, ns.swf_file)
	except KeyboardInterrupt:
		pass
	except Exception as e:
		print("ERROR:", e, file=sys.stderr)
		print()
		sys.exit(1)
	finally:
		if created:
			print(f'SWF FILE "{ns.swf_file}" CREATED')
		else:
			print("FAILED TO CREATE SWF FILE")