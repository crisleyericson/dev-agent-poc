import test from 'node:test';
import assert from 'node:assert/strict';
import { add, max } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('max returns the greater number', () => {
  assert.equal(max(3, 7), 7);
});
