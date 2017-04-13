### Resource Type: Fiile

### Properties:

Shares all the same atttributes with the Puppet [file type](https://docs.puppet.com/puppet/latest/type.html#file)

### Naming:

When creating a File resource you can either create a single file or use a shell glob.

### Examples

```yaml
:resources:
      :File['/tmp/test/bar']:
        :ensure: absent
```


```yaml
:resources:
      :File['/tmp/test/*']:
        :mode: "0400"
```
```yaml
:resources:
      :File['/tmp/test/ba{r,z}']:
        :ensure: :directory
```
