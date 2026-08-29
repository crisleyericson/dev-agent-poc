import test from 'node:test';
import assert from 'node:assert/strict';
import { add, min } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('min returns the smaller number', () => {
  assert.equal(min(2, 5), 2);
});
