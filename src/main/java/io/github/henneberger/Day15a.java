package io.github.henneberger;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import lombok.val;
import org.apache.flink.util.Preconditions;

public class Day15a {
  static enum Dir {
    U,L,D,R;

    public static Dir val(char c) {
      switch (c) {
        case '>': return Dir.R;
        case '^': return Dir.U;
        case 'v': return Dir.D;
        case '<': return Dir.L;
      }
      return null;
    }
  }
  static List<StringBuilder> puzzle;
  static String fullPuzzle;
  static int width;
  public static void main(String[] args) throws IOException {
    String[] split = Files.readString(Path.of("/Users/henneberger/advent-of-code/data/day15-input.txt")).split("\n\n");
    puzzle = Arrays.stream(split[0].split("\n"))
        .map(e->new StringBuilder(e))
        .collect(Collectors.toList());
    fullPuzzle = java.lang.String.join("", puzzle);
    width = puzzle.get(0).length();

    String m = split[1].replaceAll("\\n","");

    int i = fullPuzzle.indexOf("@");
    int x = i % width;
    int y = i / width;

    System.out.println(puzzle.get(x).charAt(y));

    for (int j = 0; j < m.length(); j++) {
      Dir val = Dir.val(m.charAt(j));
      boolean didMove = move(x, y, val);
      if (didMove){
        int[] calc = calc(x, y, val);
        x = calc[0];
        y = calc[1];
      }
      print(puzzle);
    }

    System.out.println(total(puzzle));


  }

  private static int total(List<StringBuilder> puzzle) {
    int total = 0;
    for (int i = 0; i < puzzle.size(); i++) {
      for (int j = 0; j < puzzle.get(0).length(); j++) {
        if (puzzle.get(i).charAt(j) == 'O') {
          total +=100*i+j;
        }
      }
    }
    return total;
  }

  private static void print(List<StringBuilder> puzzle) {
    for (int i = 0; i < puzzle.size(); i++) {
      System.out.println(puzzle.get(i).toString());
    }
  }

  private static boolean move(int x, int y, Dir val) {
    char c = puzzle.get(x).charAt(y);
    if (c == '#') {
      return false;
    } else if (c == '.') {
      return true;
    }

    assert c == 'O' || c == '@';

    int[] calc = calc(x, y, val);
    boolean move = move(calc[0], calc[1], val);
    if (move) {
      puzzle.get(calc[0])
          .setCharAt(calc[1], puzzle.get(x).charAt(y));
      puzzle.get(x).setCharAt(y, '.');

    }

    return move;
  }

  private static int[] calc(int x, int y, Dir val) {
    switch (val) {
      case U:
        return new int[]{x-1, y};
      case L:
        return new int[]{x, y-1};
      case D:
        return new int[]{x+1, y};
      case R:
        return new int[]{x, y+1};
    }
    throw new RuntimeException();
  }

}
