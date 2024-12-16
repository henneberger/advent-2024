package io.github.henneberger;

import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.Value;

public class Day16a {
  public static void main(String[] args) throws IOException {
    String s = "###############\n"
        + "#.......#....E#\n"
        + "#.#.###.#.###.#\n"
        + "#.....#.#...#.#\n"
        + "#.###.#####.#.#\n"
        + "#.#.#.......#.#\n"
        + "#.#.#####.###.#\n"
        + "#...........#.#\n"
        + "###.#.#####.#.#\n"
        + "#...#.....#.#.#\n"
        + "#.#.#.###.#.#.#\n"
        + "#.....#...#.#.#\n"
        + "#.###.#.#.#.#.#\n"
        + "#S..#.....#...#\n"
        + "###############";
    List<StringBuilder> puzzle = Arrays.stream( s.split("\\n")).map(e->new StringBuilder(e))
        .collect(Collectors.toList());

    int width = puzzle.get(0).length();
//    String[] split = Files.readString(Path.of("/Users/henneberger/advent-of-code/data/day15-input.txt")).split("\n\n");

    PriorityQueue<Pos> priorityQueue = new PriorityQueue(
        Comparator.comparingInt((Pos o) -> o.cost));

    Set<Visited> visited = new HashSet<>();
    priorityQueue.add(new Pos(0, s.indexOf("S") % (width+1),
        s.indexOf("S") / (width+1), Dir.E));

    while (!priorityQueue.isEmpty()) {
      Pos poll = priorityQueue.poll();
      int x = poll.x;
      int y = poll.y;
      int cost = poll.cost;
      Dir dir = poll.direction;
      Visited v = new Visited(x, y);
      if (visited.contains(v)) {
        continue;
      }
      visited.add(v);

      System.out.printf("%d, %d : %s\n", x, y,
          puzzle.get(y).charAt(x));

      if (puzzle.get(y).charAt(x) == 'E') {
        System.out.println(cost);
        break;
      }

      if (canMove(puzzle.get(y).charAt(x+1))) {
        priorityQueue.add(new Pos(dir == Dir.E ? cost + 1 : cost + 1001,
            x+1, y,
            Dir.E));
      }

      if (canMove(puzzle.get(y+1).charAt(x))) {
        priorityQueue.add(new Pos(dir == Dir.S ? cost + 1 : cost + 1001,
            x, y+1,
            Dir.S));
      }
      if (canMove(puzzle.get(y).charAt(x-1))) {
        priorityQueue.add(new Pos(dir == Dir.W ? cost + 1 : cost + 1001,
            x-1, y,
            Dir.W));
      }

      if (canMove(puzzle.get(y-1).charAt(x))) {
        priorityQueue.add(new Pos(dir == Dir.N ? cost + 1 : cost + 1001,
            x, y-1,
            Dir.N));
      }
    }



  }

  private static boolean canMove(char c) {
    return c=='.' ||c=='E';
  }

  public static enum Dir {
    N, S, E, W
  }
  @Value
  public static class Pos {
    int cost;
    int x;
    int y;
    Dir direction;
  }
  @Value
  public static class Visited {
    int x;
    int y;
  }
}
