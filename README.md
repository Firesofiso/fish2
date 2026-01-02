# fish2
An ashita v4 addon to automatically re-cast after completing the reel-in in any way (give up, catch, break, etc)

## Debugging incoming messages

To inspect the exact server messages (raw and normalized) that are driving catches, use:

```
/fish2 debug on
```

With debug enabled, press **Esc** to echo the most recent incoming message. Use `/fish2 debug off` to disable the echoes or `/fish2 debug` with no arguments to toggle the setting.
