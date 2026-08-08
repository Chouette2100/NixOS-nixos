# { config, pkgs, ... }:
{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [ 
      hplip 
      gutenprint
      # その他必要なドライバー
    ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "mint223ipp";
        location = "mint223";
        # CUPS Web UIで確認したプリンタ名をURIエンコードして指定
        deviceUri = "ipp://mint223:631/printers/DCP-J925N";
        # IPP Everywhere対応プリンタなら "everywhere" でOK
        model = "everywhere";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "mint223ipp";
  };
}
