{ lib, config, ... }:
{
  clan.core.networking.zerotier.networkId = lib.mkDefault (
    builtins.readFile (config.clan.core.clanDir + "/machines/samira/facts/zerotier-network-id")
  );
}
