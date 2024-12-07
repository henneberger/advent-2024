package io.github.henneberger;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

public class Day6b {

  static int len = 0;
  static int height = 0;
  static Map<String, Integer> dedup = new HashMap<>();
  static Queue<QObj> main = new ArrayDeque<>();
  static Queue<QObj> check = new ArrayDeque<>();
  public static void main(String[] args) throws IOException {

//    Scanner in = new Scanner(System.in);
//    String line;
//    StringBuilder builder = new StringBuilder();
//    while (!(line = in.nextLine()).isEmpty()) {
//      len = line.length();
//      builder.append(line);
//      height++;
//    }
    StringBuilder builder = new StringBuilder(Files.readString(
        Path.of("/Users/henneberger/advent-of-code/data/day6-input.txt")).replaceAll("\\\n", ""));
    len = 130;
    height = 130;

    int oPos = builder.indexOf("^");
    main.add(new QObj(builder, new StringBuilder(builder), true, oPos));

    // Do a single step
    int i = 0;
    solveMain();

    int sum = 0;
    while (!check.isEmpty()) {
      i++;
      QObj poll = check.poll();
      String string = poll.original.toString();
      if (dedupePos.contains(string)) continue;
      dedupePos.add(string);
      main.add(poll);
      dedup.clear();

      int i1 = solveMain();
      if (i1 != 0) {
        int s = poll.newPuzzlePos;
        System.out.printf("(%d, %d) %d\n", s/len, s%len, s);
        sum++;
      }
    }
    System.out.println(i + ": " + sum);
  }

  static Set<String> dedupePos = new HashSet<>();

  public static int solveMain() {
    while (!main.isEmpty()) {
      QObj s = main.poll();
      StringBuilder grid = s.modified;
      StringBuilder original = s.original;

      int uPos = grid.indexOf("^");
      int rPos = grid.indexOf(">");
      int dPos = grid.indexOf("v");
      int lPos = grid.indexOf("<");

      int pos = uPos != -1 ? uPos : rPos != -1 ? rPos : dPos != -1 ? dPos : lPos;

      if (pos == -1) {
        return 0; //completed
      }

      String s1 = grid.toString();
      Integer i1 = dedup.get(s1); //dedupe guard
      dedup.put(s1, i1 == null ?  1 : i1+1);
      if (i1 !=null) {
        return 1;
      }

      if (s.isMain && original.charAt(pos) == '.' &&
          ((rPos != -1 && charAt(grid, rPos + 1) != '#') || //is Move
              (lPos != -1 &&charAt(grid, lPos - 1) != '#') ||
              (uPos != -1 &&charAt(grid, uPos - len) != '#') ||
              (dPos != -1 &&charAt(grid, dPos + len) != '#'))) {
        StringBuilder b = new StringBuilder(original);
        b.setCharAt(pos, '#');
        check.add(new QObj(b, b, false, pos));
      }

      //Exit positions
      if (uPos != -1 && uPos - len < 0) { //exit up
        grid.setCharAt(uPos, 'X');
      } else if (rPos != -1 && rPos % len > (rPos + 1) % len) { //exit right
        grid.setCharAt(rPos, 'X');
      } else if (dPos != -1 && (dPos + len) > grid.length()) { //exit down
        grid.setCharAt(dPos, 'X');
      } else if (lPos != -1 && lPos % len < (lPos - 1) % len) { //exit left
        grid.setCharAt(lPos, 'X');
      } else if (uPos != -1 && charAt(grid, uPos - len) != '#') { // move up
        grid.setCharAt(uPos, 'X');
        grid.setCharAt(uPos - len, '^');
      } else if (uPos != -1 && charAt(grid, uPos - len) == '#') { //rotate up
        grid.setCharAt(uPos, '>');
      } else if (rPos != -1 && charAt(grid, rPos + 1) != '#') { // move right
        grid.setCharAt(rPos, 'X');
        grid.setCharAt(rPos + 1, '>');
      } else if (rPos != -1 && charAt(grid, rPos + 1) == '#') { //rotate right
        grid.setCharAt(rPos, 'v');
      } else if (dPos != -1 && charAt(grid, dPos + len) != '#') { // move down
        grid.setCharAt(dPos, 'X');
        grid.setCharAt(dPos + len, 'v');
      } else if (dPos != -1 && charAt(grid, dPos + len) == '#') { //rotate down
        grid.setCharAt(dPos, '<');
      } else if (lPos != -1 && charAt(grid, lPos - 1) != '#') { // move left
        grid.setCharAt(lPos, 'X');
        grid.setCharAt(lPos - 1, '<');
      } else if (lPos != -1 && charAt(grid, lPos - 1) == '#') { //rotate left
        grid.setCharAt(lPos, '^');
      } else {
        throw new RuntimeException();
      }

      main.add(new QObj(original, grid, s.isMain, s.newPuzzlePos));
    }
    return 0;
  }

  public static void print(StringBuilder builder) {
    for (int i = 0; i < builder.length(); i++) {
      if (i % len == 0) {
        System.out.println();
      }
      System.out.print(builder.charAt(i));
    }
    System.out.println();
  }

  private static char charAt(StringBuilder grid, int i) {
    return (i < 0 || i > grid.length()) ? ' ' : grid.charAt(i);
  }

  public static class QObj {

    private final int newPuzzlePos;
    StringBuilder original;
    StringBuilder modified;
    boolean isMain;

    public QObj(StringBuilder original, StringBuilder modified, boolean isMain, int newPuzzlePos) {
      this.original = original;
      this.modified = modified;
      this.isMain = isMain;
      this.newPuzzlePos = newPuzzlePos;
    }
  }
}
