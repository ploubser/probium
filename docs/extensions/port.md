### Resource Type: Port

### Properties:
- **open** `boolean` - true if the port is open, false if not
- **ssl** `boolean` - true if ssl is enabled on the port, false if not

### Naming:

- \d+ The port number
- \d+-\d+ The port range

### Examples

```yaml
:Port['23']:
        :open: false
```

```yaml
:Port['43']:
        :open: true
        :ssl: true
```

```yaml
:Port['1000-2000']:
        :open: false
```
