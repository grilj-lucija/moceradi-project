import { render, screen } from '@testing-library/react';
import Auth from './Auth';

test('prikaze prijavni obrazec', ()=> {
  render(<Auth />);
  expect(screen.getByPlaceholderText(/email/i)).toBeInTheDocument();
  expect(screen.getByPlaceholderText(/geslo/i)).toBeInTheDocument();
});

test('prikaze gumb za prijavo', () => {
  render(<Auth />);
  expect(screen.getByText(/prijavi se/i)).toBeInTheDocument();
});

test('prikaze link za registracijo', () => {
  render(<Auth />);
  expect(screen.getByText(/registriraj se/i)).toBeInTheDocument();
});
