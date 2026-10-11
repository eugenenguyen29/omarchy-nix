# omarchy-nix — agent rules

## Delegation

- Hand implementation work to a subagent. Don't write the change yourself.
- When it reports done, start **two separate** agents to verify the change.
  Each one checks it on its own. Don't share one agent's verdict with the
  other.
- A trivial change needs only **one** verifying agent. Trivial means a few
  lines in one file that change no behavior: an ignore entry, a typo, a
  comment, a wording fix in a doc. If in doubt, use two.
- It's done only when every verifying agent passes it. If one finds a
  problem, send it back to the implementer and verify again with new agents.
