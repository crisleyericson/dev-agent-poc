import test from 'node:test';
import assert from 'node:assert/strict';
import { add, power } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('power raises a number to an exponent', () => {
  assert.equal(power(2, 3), 8);
});
