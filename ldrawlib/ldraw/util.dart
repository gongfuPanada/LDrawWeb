// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

String normalizePath(String path) {
  return path.toLowerCase().replaceAll('\\', '/');
}