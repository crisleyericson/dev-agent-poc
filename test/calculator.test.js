import test from 'node:test';
import assert from 'node:assert/strict';
import { absolute, add } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('absolute returns the absolute value', () => {
  assert.equal(absolute(-5), 5);
  assert.equal(absolute(5), 5);
  assert.equal(absolute(0), 0);
});
