{
  pkgs,
  lib,
  ...
}: let
  helpers = rec {
    createConfigFromTemplate = {
      template,
      destination,
      substitutions ? {},
      createDirs ? true,
    }: let
      templateFile = ../config-templates + "/${template}";
      sedCommands = lib.concatStringsSep "; " (
        lib.mapAttrsToList (
          placeholder: value: "s|@${placeholder}@|${toString value}|g"
        )
        substitutions
      );
    in ''
      ${lib.optionalString createDirs "mkdir -p $(dirname ${destination})"}
      ${pkgs.gnused}/bin/sed '${sedCommands}' ${templateFile} > ${destination}
    '';

    updateConfigIfExists = {
      configFile,
      updates,
    }: let
      sedCommands = lib.concatStringsSep "; " (
        lib.mapAttrsToList (
          pattern: replacement: "s|${pattern}|${replacement}|g"
        )
        updates
      );
    in ''
      if [ -f ${configFile} ]; then
        ${pkgs.gnused}/bin/sed -i '${sedCommands}' ${configFile}
      fi
    '';

    ensureConfigFromTemplate = {
      template,
      destination,
      substitutions ? {},
      updates ? {},
      createDirs ? true,
    }: let
      createNew = createConfigFromTemplate {
        inherit template destination substitutions createDirs;
      };
      updateExisting = lib.optionalString (updates != {}) (updateConfigIfExists {
        configFile = destination;
        inherit updates;
      });
    in ''
      if [ -f ${destination} ]; then
        ${updateExisting}
      else
        ${createNew}
      fi
    '';
  };
in
  helpers
