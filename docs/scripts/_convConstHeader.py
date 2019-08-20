#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import re
import glob
import yaml

def usage():
	print("Usage: _convConstHeader.py [fDefine]")

class Writer:
	def __init__(self):
		self.buf = ""
	def write(self, line, tab=0):
		for i in range(tab):
			self.buf += "\t"
		self.buf += "%s\n"%line

def executeVar(fOut, fDefines):
	defines = {}
	varDefines = {}
	flagDefines = {}
	for fDefine in fDefines.split(","):
		f = open(fDefine)
		data = yaml.load(f, Loader=yaml.SafeLoader)
		if "const" in data: # 定数
			defines.update(data["const"])
		if "var" in data: # 変数の定数
			varDefines.update(data["var"])
		if "flag" in data: # フラグの定数
			flagDefines.update(data["flag"])
		f.close()
	
	writer = Writer()
	writer.write("package esc;")
	writer.write("");
	writer.write("class EscVar {");
	writer.write("// ■変数", 1);
	for k, v in varDefines.items():
		writer.write("public static inline var %s:Int = %d;"%(k, v), 1);
	writer.write("var _tbl:Map<String, Int> = [", 1)
	for k, v in varDefines.items():
		writer.write("\"%s\" => %d,"%(k, v), 2)
	writer.write("];", 1)
	writer.write("public function get(k:String):Int {", 1);
	writer.write(	"if(_tbl.exists(k)) {", 2);
	writer.write(		"return _tbl[k];", 3);
	writer.write(	"}", 2);
	writer.write(	"return 0;", 2);
	writer.write("}", 1);
	
	writer.write("}");
	f = open(fOut, "w")
	f.write(writer.buf)
	f.close()
	
def executeFlag(fOut, fdefines):
	defines = {}
	varDefines = {}
	flagDefines = {}
	for fDefine in fDefines.split(","):
		f = open(fDefine)
		data = yaml.load(f, Loader=yaml.SafeLoader)
		if "const" in data: # 定数
			defines.update(data["const"])
		if "var" in data: # 変数の定数
			varDefines.update(data["var"])
		if "flag" in data: # フラグの定数
			flagDefines.update(data["flag"])
		f.close()
	
	writer = Writer()
	writer.write("package esc;")
	writer.write("");
	writer.write("class EscFlag {");
	writer.write("// ■フラグ", 1);
	for k, v in flagDefines.items():
		writer.write("public static inline var %s:Int = %d;"%(k, v), 1);
	writer.write("var _tbl:Map<String, Int> = [", 1)
	for k, v in flagDefines.items():
		writer.write("\"%s\" => %d,"%(k, v), 2)
	writer.write("];", 1)
	writer.write("public function get(k:String):Int {", 1);
	writer.write(	"if(_tbl.exists(k)) {", 2);
	writer.write(		"return _tbl[k];", 3);
	writer.write(	"}", 2);
	writer.write(	"return 0;", 2);
	writer.write("}", 1);
	
	writer.write("}");
	f = open(fOut, "w")
	f.write(writer.buf)
	f.close()
	
def execute(fOut, fDefines):
	defines = {}
	varDefines = {}
	flagDefines = {}
	for fDefine in fDefines.split(","):
		f = open(fDefine)
		data = yaml.load(f, Loader=yaml.SafeLoader)
		if "const" in data: # 定数
			defines.update(data["const"])
		if "var" in data: # 変数の定数
			varDefines.update(data["var"])
		if "flag" in data: # フラグの定数
			flagDefines.update(data["flag"])
		f.close()
	
	writer = Writer()
	writer.write("package esc;")
	writer.write("");
	writer.write("class EscConst {");
	writer.write("// ■定数", 1);
	for k, v in defines.items():
		writer.write("public static inline var %s:Int = %d;"%(k, v), 1)
	
	writer.write("}");
	f = open(fOut, "w")
	f.write(writer.buf)
	f.close()

def main(fDefines):
	# ルートディレクトリ取得
	root = os.path.dirname(os.path.abspath(__file__))
	execute("%s/../../source/esc/EscConst.hx"%root, fDefines)
	executeVar("%s/../../source/esc/EscVar.hx"%root, fDefines)
	executeFlag("%s/../../source/esc/EscFlag.hx"%root, fDefines)
if __name__ == '__main__':
	args = sys.argv
	argc = len(sys.argv)
	if argc < 2:
		# 引数が足りない
		print(args)
		print("Error: Not enough parameter. given=%d require=%d"%(argc, 2))
		usage()
		quit()

	# 定数定義ファイル
	fDefines = args[1]

	main(fDefines)
