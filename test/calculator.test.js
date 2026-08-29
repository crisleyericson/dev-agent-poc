import test from 'node:test';
import assert from 'node:assert/strict';
import { add, mod } from '../src/calculator.js';

test('add sums two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('mod returns the remainder of a division', () => {
  assert.equal(mod(10, 3), 1);
});
