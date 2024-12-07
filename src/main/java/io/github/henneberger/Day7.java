package io.github.henneberger;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;

public class Day7 {

  public static void main(String[] args) {
    Scanner in = new Scanner(System.in);
    String line;
    BigInteger total = BigInteger.ZERO;
    BigInteger total2 = BigInteger.ZERO;
    int x = 0;
    while (!(line = in.nextLine()).isEmpty()) {
      x++;
      line = line.trim();
      String[] split = line.split(": ");
      BigInteger target = new BigInteger(split[0]);
      List<BigInteger> nums = Arrays.stream(split[1].split(" ")).map(BigInteger::new)
          .collect(Collectors.toList());

      boolean valid = problem1(target, nums, 0, BigInteger.ZERO);

      if (valid) {
        total = total.add(target);
      }

      boolean valid2 = problem2(target, nums, 0, BigInteger.ZERO);

      if (valid2) {
        total2 = total2.add(target);
      }
    }
    System.out.println(total);
    System.out.println(total2);
  }

  private static boolean problem2(BigInteger target, List<BigInteger> nums, int idx,
      BigInteger sumSoFar) {
    if (idx == nums.size()) {
      return target.equals(sumSoFar);
    }

    boolean b = problem2(target, nums, idx+1, new BigInteger(
        (sumSoFar.equals(BigInteger.ZERO) ? "" : sumSoFar.toString()) +
            nums.get(idx).toString()));
    if (b) {
      return b;
    }
    if (problem2(target, nums, idx + 1, sumSoFar.add(nums.get(idx)))) {
      return true;
    }

    if (idx == 0) {
      return problem2(target, nums, idx + 2, nums.get(idx).multiply(nums.get(idx+1)));
    } else {
      return problem2(target, nums, idx + 1, sumSoFar.multiply(nums.get(idx)));
    }
  }

  private static boolean problem1(BigInteger target, List<BigInteger> nums, int idx,
      BigInteger sumSoFar) {
    if (idx == nums.size()) {
      return target.equals(sumSoFar);
    }
    if (problem1(target, nums, idx + 1, sumSoFar.add(nums.get(idx)))) {
      return true;
    }
    if (idx == 0) {
      return problem1(target, nums, idx + 2, nums.get(idx).multiply(nums.get(idx+1)));
    } else {
      return problem1(target, nums, idx + 1, sumSoFar.multiply(nums.get(idx)));
    }
  }
}
