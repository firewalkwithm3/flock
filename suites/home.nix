{
  programs.git = {
    enable = true;
    userEmail = "mail@fern.garden";
    userName = "Fern Garden";
  };

  programs.aria2 = {
    enable = true;
    settings = {
      max-concurrent-downloads = 5;
      max-connection-per-server = 16;
      min-split-size = "8M";
      split = 32;
      disk-cache = "64M";
      file-allocation = "falloc";
    };
  };
}
