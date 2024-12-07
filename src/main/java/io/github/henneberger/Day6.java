package io.github.henneberger;

import java.util.HashSet;
import java.util.Objects;
import java.util.Scanner;
import java.util.Set;

public class Day6 {

  static int len = 0;
  static int height = 0;

  public static void main(String[] args) {
    Scanner in = new Scanner(System.in);
    String line;
    StringBuilder builder = new StringBuilder();
    while (!(line = in.nextLine()).isEmpty()) {
      len = line.length();
      builder.append(line);
      height++;
    }

    int pos;
    int dir;
    if (builder.indexOf("^") != -1) {
      pos = builder.indexOf("^");
      dir = Dir.U.ordinal();
    } else if (builder.indexOf("v") != -1) {
      pos = builder.indexOf("v");
      dir = Dir.D.ordinal();
    } else if (builder.indexOf("<") != -1) {
      pos = builder.indexOf("<");
      dir = Dir.L.ordinal();
    } else {
      pos = builder.indexOf(">");
      dir = Dir.R.ordinal();
    }
    int startPos = pos;
    Set<Integer> seen = new HashSet<>();
    Set<Integer> all = new HashSet<>();
    outer: while (true) {
      if (pos < 0 || pos > builder.length()) {
        break outer;
      }
      all.add(pos);

      switch (dir) {
        case 0:
          if (builder.charAt(pos-len) != '#') {
            builder.setCharAt(pos - len, '#');
            builder.setCharAt(startPos, '^');
            builder.setCharAt(pos, '.');
            boolean hasloop = hasloop(builder);
            if (hasloop) {
              seen.add(pos-len);
            }
            builder.setCharAt(startPos, '.');
            builder.setCharAt(pos - len, '.');
          }
          builder.setCharAt(pos, '.');
          if (builder.charAt(pos-len) != '#') {
            pos -= len;
            builder.setCharAt(pos, '^');
          } else {
            dir = Dir.R.ordinal();

            builder.setCharAt(pos, '>');
          }
          break;
        case 1:
          if (pos+len > builder.length()) break outer;
          if (builder.charAt(pos+len) != '#') {
            builder.setCharAt(pos + len, '#');
            builder.setCharAt(startPos, '^');
            builder.setCharAt(pos, '.');
            boolean hasloop2 = hasloop(builder);
            if (hasloop2) {
              seen.add(pos+len);
            }
            builder.setCharAt(startPos, '.');
            builder.setCharAt(pos + len, '.');
          }
          builder.setCharAt(pos, '.');
          if (builder.charAt(pos+len) != '#') {
            pos += len;
            builder.setCharAt(pos, 'v');
          } else {
            dir = Dir.L.ordinal();

            builder.setCharAt(pos, '<');
          }
          break;
        case 2:
          if (pos % len < (pos-1) %len) break outer;
          if (builder.charAt(pos-1) != '#') {
            builder.setCharAt(pos - 1, '#');
            builder.setCharAt(startPos, '^');
            builder.setCharAt(pos, '.');
            boolean hasloop3 = hasloop(builder);
            if (hasloop3) {
              seen.add(pos-1);
            }
            builder.setCharAt(startPos, '.');
            builder.setCharAt(pos - 1, '.');
          }
          builder.setCharAt(pos, '.');
          if (builder.charAt(pos-1) != '#'){
            pos -= 1;
            builder.setCharAt(pos, '<');
          } else {
            dir = Dir.U.ordinal();

            builder.setCharAt(pos, '^');
          }
          break;
        case 3:
          if (pos % len > (pos+1) %len) break outer;
          if (builder.charAt(pos+1) != '#') {
            builder.setCharAt(pos + 1, '#');
            builder.setCharAt(startPos, '^');
            builder.setCharAt(pos, '.');
            boolean hasloop4 = hasloop(builder);
            if (hasloop4) {
              seen.add(pos+1);
            }
            builder.setCharAt(startPos, '.');
            builder.setCharAt(pos + 1, '.');
          }
          builder.setCharAt(pos, '.');
          if (builder.charAt(pos+1) != '#') {
            pos += 1;
            builder.setCharAt(pos, '>');
          } else {
            dir = Dir.D.ordinal();

            builder.setCharAt(pos, 'v');
          }
          break;
      }

    }

    System.out.println(seen.size());
    System.out.println(all.size());
  }

  public static class Seen {
    int pos;
    int dir;

    public Seen(int pos, int dir) {
      this.pos = pos;
      this.dir = dir;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      Seen seen = (Seen) o;
      return pos == seen.pos && dir == seen.dir;
    }

    @Override
    public int hashCode() {
      return Objects.hash(pos, dir);
    }
  }

  enum Dir {U,D,L,R}
  public static boolean hasloop(StringBuilder builder) {
    int pos;
    int dir;
    if (builder.indexOf("^") != -1) {
      pos = builder.indexOf("^");
      dir = Dir.U.ordinal();
    } else if (builder.indexOf("v") != -1) {
      pos = builder.indexOf("v");
      dir = Dir.D.ordinal();
    } else if (builder.indexOf("<") != -1) {
      pos = builder.indexOf("<");
      dir = Dir.L.ordinal();
    } else {
      pos = builder.indexOf(">");
      dir = Dir.R.ordinal();
    }
    Set<Seen> seen = new HashSet<>();

    while (true) {
      Seen seen1 = new Seen(pos, dir);
      if (seen.contains(seen1)) return true;
      seen.add(seen1);

      switch (dir) {
        case 0:
          if (pos - len < 0 )return false;
          if (builder.charAt(pos - len) == '#') {
            dir = Dir.R.ordinal();
          } else {
            pos -= len;
          }
          break;
        case 1:
          if (pos + len > builder.length() )return false;
          if (builder.charAt(pos + len) == '#') {
            dir = Dir.L.ordinal();
          } else {
            pos += len;
          }
          break;
        case 2:
          if (pos - 1 <0 )return false;
          if (pos % len < (pos-1) %len) return false;
          if (builder.charAt(pos - 1) == '#') {
            dir = Dir.U.ordinal();
          } else {
            pos -= 1;
          }
          break;
        case 3:
          if (pos + 1 > builder.length()) return false;
          if (pos % len > (pos+1) %len) return false;
          if (builder.charAt(pos + 1) == '#') {
            dir = Dir.D.ordinal();
          } else {
            pos += 1;
          }
          break;
      }
      if (pos < 0 || pos > builder.length()) {
        return false;
      }
    }
  }

  public static void print(int len, int height, StringBuilder builder) {
    for (int i = 0; i < builder.length(); i++) {
      if (i % len == 0) {
        System.out.println();
      }
      System.out.print(builder.charAt(i));
    }
    System.out.println();
  }

}
