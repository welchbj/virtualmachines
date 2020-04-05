# Virtual Machines

A collection of simple vagrant templates.

## Removing a VM

Check which boxes are installed with:

```sh
vagrant global-status --prune
```

Delete the one you want to with:

```sh
vagrant destroy <hash>
```

## Troubleshooting

If you hang on SSH key authentication during `vagrant up`, look at [this thread](https://github.com/hashicorp/vagrant/issues/8157) for potential solutions.

For issues with vbox guest additions, [this StackOverflow answer](https://superuser.com/a/966411) and [this guide](https://linuxize.com/post/how-to-install-virtualbox-guest-additions-in-ubuntu/) may prove fruitful.

For issues with setting the screen resolution, see [this StackOverflow Answer](https://askubuntu.com/a/377944).