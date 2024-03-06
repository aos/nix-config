{
  disko.devices = {
    disk = {
      nvme0n1 = {
	type = "disk";
	device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23523B800081";
	content = {
	  type = "gpt";
	  partitions = {
	    ESP = {
	      size = "512M";
	      type = "EF00";
	      content = {
		type = "filesystem";
		format = "vfat";
		mountpoint = "/boot";
		mountOptions = [
		  "defaults"
		];
	      };
	    };
	    luksKey = {
	      size = "32M";
	      type = "8300";
	      content = {
		type = "luks";
		name = "cryptkey";
		mountpoint = "/dev/mapper/cryptkey";
		extraFormatArgs = [ "--type luks1" ];
		postCreateHook = ''
		  dd if=/dev/urandom of=/dev/mapper/cryptkey count=32 bs=1024 status=progress
		'';
	      };
	    };
	    swap = {
	      size = "1G";
	      type = "8300";
	      content = {
		type = "luks";
		name = "cryptswap";
		extraFormatArgs = [ "--type luks1" ];
		settings = {
		  keyFile = "/dev/mapper/cryptkey";
		  keyFileSize = 8192;
		};
		content = {
		  type = "swap";
		};
	      };
	    };
	    root = {
	      size = "100%";
	      content = {
		type = "luks";
		name = "cryptroot";
		extraFormatArgs = [ "--type luks1" ];
		settings = {
		  allowDiscards = true;
		  keyFile = "/dev/mapper/cryptkey";
		  keyFileSize = 8192;
		};
		postCreateHook = ''
		  cryptsetup luksAddKey --type luks1 \
					--key-file ''${settings[keyFile]} \
					--keyfile-size ''${settings[keyFileSize]} \
					''$device /tmp/disk.key
		'';
		content = {
		  type = "btrfs";
		  extraArgs = [ "-f" ];
		  subvolumes = {
		    "/root" = {
		      mountpoint = "/";
		      mountOptions = [ "compress=zstd" "noatime" ];
		    };
		    "/home" = {
		      mountpoint = "/home";
		      mountOptions = [ "compress=zstd" "noatime" ];
		    };
		    "/nix" = {
		      mountpoint = "/nix";
		      mountOptions = [ "compress=zstd" "noatime" ];
		    };
		  };
		};
	      };
	    };
	  };
	};
      };
    };
  };
}
