package io.github.henneberger.day7;

import org.apache.flink.table.functions.AggregateFunction;

public class LastValueCalculator extends AggregateFunction<Long, MyAgg> {


  public void accumulate(MyAgg acc, Long nextValue, String operator) {
    if (acc.value == null) {
      acc.value = nextValue;
      return;
    }

    switch (operator) {
      case "||":
        try {
          acc.value = Long.valueOf(acc.value + "" + nextValue);
        } catch (Exception e) {
          acc.value = Long.MIN_VALUE;
        }
        break;
      case "*":
        acc.value = acc.value * nextValue;
        break;
      case "+":
        acc.value = acc.value + nextValue;
        break;
    }
  }

  @Override
  public Long getValue(MyAgg o) {
    return o.value;
  }

  @Override
  public MyAgg createAccumulator() {
    return new MyAgg();
  }
}
