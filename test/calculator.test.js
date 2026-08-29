import test from 'node:test';
import assert from 'node:assert/strict';
import { add, divide } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('divide divides two numbers', () => {
  assert.equal(divide(12, 3), 4);
});
