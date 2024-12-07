package io.github.henneberger;

import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.Scanner;

/**
 * A non-working but more flink-y solution. Uses a queue and processes one at a time.
 * We do recursion by re-emitting back to the queue.
 * - use row number to determine if there is a cycle (need to emit only one per position)
 * - right now it does the main then does the check queue, but this can be one
 * - pull out the conditions to emit to the bottom so it can be a filter condition
 */

public class Day6b {

  static int len = 0;
  static int height = 0;
  static Map<String, Integer> dedup = new HashMap<>();
  static Queue<QObj> main = new ArrayDeque<>();
  static Queue<QObj> check = new ArrayDeque<>();
  public static void main(String[] args) {

    Scanner in = new Scanner(System.in);
    String line;
    StringBuilder builder = new StringBuilder();
    while (!(line = in.nextLine()).isEmpty()) {
      len = line.length();
      builder.append(line);
      height++;
    }

    int pos = builder.indexOf("^");
    int direction = 0;

    main.add(new QObj(builder, new StringBuilder(builder), true, pos, direction, pos, direction));

    // Do a single step
    int i = 0;
    solveMain();

    int sum = 0;
    while (!check.isEmpty()) {
      i++;
      QObj poll = check.poll();
      main.add(poll);
      dedup.clear();
      int i1 = solveMain();
      if (i1 != 0) {
        sum++;
      }
      System.out.println(i);
    }
    System.out.println(i + ": " + sum);
  }
  public static int solveMain() {
    while (!main.isEmpty()) {
      QObj s = main.poll();
      StringBuilder grid = s.modified;
      StringBuilder original = s.original;
      // Sql case when

      int uPos = s.dir == 0 ? s.pos : -1;
      int rPos = s.dir == 1 ? s.pos : -1;
      int dPos = s.dir == 2 ? s.pos : -1;
      int lPos = s.dir == 3 ? s.pos : -1;

      if (uPos == -1 && dPos == -1 && lPos == -1 && rPos == -1) {
        continue; //possible completed
      }

      String s1 = grid.toString();
      Integer i1 = dedup.get(s1);
      dedup.put(s1, i1 == null ?  1 : i1+1);
      if (i1 !=null) {
        return 1;
      }

      //Exit positions
      int newPos = s.pos;
      int newDir = s.dir;
      if (uPos != -1 && uPos - len < 0) { //exit up
        grid.setCharAt(uPos, 'X');
        newPos = -1;
      } else if (rPos != -1 && rPos % len > (rPos + 1) % len) { //exit right
        grid.setCharAt(rPos, 'X');
        newPos = -1;
      } else if (dPos != -1 && (dPos + len) > grid.length()) { //exit down
        grid.setCharAt(dPos, 'X');
        newPos = -1;
      } else if (lPos != -1 && lPos % len < (lPos - 1) % len) { //exit left
        grid.setCharAt(lPos, 'X');
        newPos = -1;
      } else if (uPos != -1 && charAt(grid, uPos - len) != '#') { // move up
        if (uPos != s.origPos && s.isMain) {
          StringBuilder b = new StringBuilder(original);
          b.setCharAt(uPos, '#');
          check.add(new QObj(original, b, false, s.origPos, s.origDir, s.origPos, s.origDir));
        }
        grid.setCharAt(uPos, 'X');
        grid.setCharAt(uPos - len, '^');
        newPos = uPos - len;
      } else if (uPos != -1 && charAt(grid, uPos - len) == '#') { //rotate up
        grid.setCharAt(uPos, '>');
        newDir = 1;
      } else if (rPos != -1 && charAt(grid, rPos + 1) != '#') { // move right
        if (s.isMain) {
          StringBuilder b = new StringBuilder(original);
          b.setCharAt(rPos, '#');
          check.add(new QObj(original, b, false, s.origPos, s.origDir, s.origPos, s.origDir));
        }

        grid.setCharAt(rPos, 'X');
        grid.setCharAt(rPos + 1, '>');
        newPos = rPos + 1;
      } else if (rPos != -1 && charAt(grid, rPos + 1) == '#') { //rotate right
        grid.setCharAt(rPos, 'v');
        newDir = 2;
      } else if (dPos != -1 && charAt(grid, dPos + len) != '#') { // move down
        if (s.isMain) {
          StringBuilder b = new StringBuilder(original);
          b.setCharAt(dPos, '#');
          check.add(new QObj(original, b, false, s.origPos, s.origDir, s.origPos, s.origDir));
        }

        grid.setCharAt(dPos, 'X');
        grid.setCharAt(dPos + len, 'v');
        newPos = dPos + len;
      } else if (dPos != -1 && charAt(grid, dPos + len) == '#') { //rotate down
        grid.setCharAt(dPos, '<');
        newDir = 3;
      } else if (lPos != -1 && charAt(grid, lPos - 1) != '#') { // move left
        if (s.isMain) {
          StringBuilder b = new StringBuilder(original);
          b.setCharAt(lPos, '#');
          check.add(new QObj(original, b, false, s.origPos, s.origDir, s.origPos, s.origDir));
        }

        grid.setCharAt(lPos, 'X');
        grid.setCharAt(lPos - 1, '<');
        newPos = lPos - 1;
      } else if (lPos != -1 && charAt(grid, lPos - 1) == '#') { //rotate left
        grid.setCharAt(lPos, '^');
        newDir = 0;
      } else {
        throw new RuntimeException();
      }

      main.add(new QObj(original, new StringBuilder(grid), s.isMain, newPos, newDir, s.origPos, s.origDir));
    }

    int j = 0;
    for (Map.Entry<String, Integer> e : dedup.entrySet()) {
      if (e.getValue() > 1 ) {
        j++;
      }
    }
    return j;

  }
  private static final char[] CHARSET = {'.', '#', '<', '^', '>', 'v', 'X'};
  private static final Map<Character, Integer> CHAR_TO_CODE = new HashMap<>();
  static {
    for (int i = 0; i < CHARSET.length; i++) {
      CHAR_TO_CODE.put(CHARSET[i], i);
    }
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

    StringBuilder original;
    StringBuilder modified;
    boolean isMain;
    int pos;
    int dir;
    int origPos;
    int origDir;

    public QObj(StringBuilder original, StringBuilder modified, boolean isMain, int pos, int dir,
        int origPos, int origDir) {
      this.original = original;
      this.modified = modified;
      this.isMain = isMain;
      this.pos = pos;
      this.dir = dir;
      this.origPos = origPos;
      this.origDir = origDir;
    }
  }
}
