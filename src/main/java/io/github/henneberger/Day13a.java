package io.github.henneberger;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class Day13a {

  static String string ="Button A: X+94, Y+34\n"
      + "Button B: X+22, Y+67\n"
      + "Prize: X=8400, Y=5400\n"
      + "\n"
      + "Button A: X+26, Y+66\n"
      + "Button B: X+67, Y+21\n"
      + "Prize: X=12748, Y=12176\n"
      + "\n"
      + "Button A: X+17, Y+86\n"
      + "Button B: X+84, Y+37\n"
      + "Prize: X=7870, Y=6450\n"
      + "\n"
      + "Button A: X+69, Y+23\n"
      + "Button B: X+27, Y+71\n"
      + "Prize: X=18641, Y=10279\n"
      + "";

  public static void main(String[] args) throws IOException {
//    String[] split = string.split("\n");
    String[] split = Files.readString(Path.of("/Users/henneberger/advent-of-code/data/day13-input.txt")).split("\n");
    int aX = -1;
    int bX = -1;
    int pX = -1;
    int aY = -1;
    int bY = -1;
    int pY = -1;
    int toks = 0;

    for (int i = 0; i < split.length; i++) {
      if (i%4==0) {
        String[] x = split[i].split(":")[1].trim().split(",");
        aX = Integer.parseInt(x[0].split("\\+")[1]);
        aY = Integer.parseInt(x[1].split("\\+")[1]);
      }
      if (i%4==1) {
        String[] x = split[i].split(":")[1].trim().split(",");
        bX = Integer.parseInt(x[0].split("\\+")[1]);
        bY = Integer.parseInt(x[1].split("\\+")[1]);
      }
      if (i%4==2) {
        String[] x = split[i].split(":")[1].trim().split(",");
        pX = Integer.parseInt(x[0].split("=")[1]);
        pY = Integer.parseInt(x[1].split("=")[1]);
      }

      if(i%4==3 || i == split.length-1) {
        long calc = compute(aX, aY, bX, bY, pX, pY);
//        System.out.println(calc);
        if (calc != Long.MAX_VALUE) {
          toks += calc;
        }
      }
    }

    System.out.println(toks);
  }

  private static long compute(int aX, int aY, int bX, int bY, int pX, int pY) {
    long min = Long.MAX_VALUE;
    for (long i = 0; i < 100; i++) {
      for (long j = 0; j < 100; j++) {
        if (i*aX+j*bX == pX && i*aY+j*bY==pY) {
          min = Math.min(3*i + j, min);
//          System.out.println(i + ":" + j);
        }
      }
    }
    return min;
  }
}
