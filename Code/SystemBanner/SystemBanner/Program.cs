﻿//Copyright (c) 2022, Aaron Wawrzyniak. MIT License Applies.
using System;
using System.Windows.Forms;
using Microsoft.Win32;

namespace SystemBanner
{
    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        /// 
        //storage for initial values to detect changes later
        public static int displayCount = System.Windows.Forms.Screen.AllScreens.Length;
        public static int displayPixelLength;
        public static int displayPixelHeight;
        public static int displayPixelHash;
        public static int[] oldBannerColor;
        public static string oldBannerText;
        //defines stock colors for basic us gov classification based on gsa form color info collected by Frank Caviggia @ https://github.com/fcaviggia/classification-banner
        public static int[] unconfiguredBannerColor = new int[6] { 255, 255, 255, 0, 0, 0 };
        public static int[] unclassifiedBannerColor = new int[6] { 0, 122, 51, 255, 255, 255 };
        public static int[] cuiBannerColor = new int[6] { 48, 31, 85, 255, 255, 255 };
        public static int[] confidentialBannerColor = new int[6] { 0, 51, 160, 255, 255, 255 };
        public static int[] secretBannerColor = new int[6] { 200, 16, 46, 255, 255, 255 };
        public static int[] topsecretBannerColor = new int[6] { 255, 103, 31, 255, 255, 255 };
        public static int[] topsecretsciBannerColor = new int[6] { 247, 234, 72, 0, 0, 0 };
        public static string unconfiguredBannerText = "Classification is not configured.";
        public static string unclassifiedBannerText = "UNCLASSIFIED";
        public static string cuiBannerText = "CUI";
        public static string confidentialBannerText = "CONFIDENTIAL";
        public static string secretBannerText = "SECRET";
        public static string topsecretBannerText = "TOP SECRET";
        public static string topsecretsciBannerText = "TOP SECRET//SCI";
        public static int[][] simpleBannerColors = new int[][] { unconfiguredBannerColor, unclassifiedBannerColor, cuiBannerColor, confidentialBannerColor, secretBannerColor, topsecretBannerColor, topsecretsciBannerColor };
        public static string[] simpleBannerTexts = { unconfiguredBannerText, unclassifiedBannerText, cuiBannerText, confidentialBannerText, secretBannerText, topsecretBannerText, topsecretsciBannerText };
        //set default color and text as unconfigured in case first run/registry data does not exist
        public static int[] bannerColor = unconfiguredBannerColor;
        public static string bannerText = unconfiguredBannerText;

        [STAThread]
        static void Main()
        {
            //store initial display data
            displayCount = System.Windows.Forms.Screen.AllScreens.Length;
            for (int i = 0; i < System.Windows.Forms.Screen.AllScreens.Length; i++)
            {
                displayPixelLength += System.Windows.Forms.Screen.AllScreens[i].Bounds.Width;
                displayPixelHeight += System.Windows.Forms.Screen.AllScreens[i].Bounds.Height;
                displayPixelHash += System.Windows.Forms.Screen.AllScreens[i].Bounds.GetHashCode();
            }
            //if they exist, grab color and text user configuration from the registry set manually or via group policy
            GetRegValues();
            //store initial color and text
            oldBannerColor = bannerColor;
            oldBannerText = bannerText;
            //for each screen that exists, build me a new banner on that screen with color and text values defined.
            BuildBanners();
            //set a timer for refreshing banners if needed
            RefreshBannerTimer();
            //on your marks, get set...
            Application.Run();
        }
        private static void GetRegValues()
        {
            //grab registry key and see if it exists
            using (var hklm = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64))
            using (var checkKey = hklm.OpenSubKey(@"SOFTWARE\Policies\SystemBanner", RegistryKeyPermissionCheck.ReadSubTree))
            {
                if (checkKey != null)
                {
                    var key = hklm.OpenSubKey(@"SOFTWARE\Policies\SystemBanner", RegistryKeyPermissionCheck.ReadSubTree);
                    //check DWORD registry values for custom color if they exist, and if so, grab them
                    for (int i = 0; i < bannerColor.Length; i++)
                    {
                        var value = key.GetValue(i.ToString());
                        if (value != null)
                        {
                            value = key.GetValue(i.ToString());
                            bannerColor[i] = (int)value;
                        }
                        else
                        {
                            bannerColor[i] = unconfiguredBannerColor[i]; 
                        }

                    }
                    //check SZ registry value for custom text if it exists, and if so, grab it
                    var textValue = key.GetValue("Text");
                    if (textValue != null)
                    {
                        textValue = key.GetValue("Text");
                        bannerText = (string)textValue;
                    }
                    //override custom if simple value is set
                    var simpleValue = key.GetValue("Simple");
                    if (simpleValue != null)
                    {
                        simpleValue = key.GetValue("Simple");
                        if ((int)simpleValue != 0)
                        {
                            bannerColor = simpleBannerColors[(int)simpleValue];
                            bannerText = simpleBannerTexts[(int)simpleValue];
                        }
                    }
                }
                //if no reg values, set to not configured.
                else
                {
                    bannerColor = simpleBannerColors[0];
                    bannerText = simpleBannerTexts[0];
                }
            }
        }
        private static void BuildBanners()
        {
            for (int i = 0; i < System.Windows.Forms.Screen.AllScreens.Length; i++)
            {
                Banner bannerInstance = new Banner(i, bannerColor, bannerText);
                bannerInstance.Show();
                AppBar AppBarInstance = new AppBar(i);
            }
        }
        private static void RebuildBanners()
        {
            for (int i = Application.OpenForms.Count - 1; i >= 0; i--)
            {
                Application.OpenForms[i].Close();
            }
            BuildBanners();
        }
            
        private static void RefreshBannerTimer()
        {
            Timer bannerTimer = new Timer();
            bannerTimer.Interval = (10 * 100); // 1 sec
            bannerTimer.Tick += new EventHandler(RefreshBannerTick);
            bannerTimer.Start();
        }
        private static void RefreshBannerTick(object sender, EventArgs e)
        {
            GetRegValues();
            if (displayCount != System.Windows.Forms.Screen.AllScreens.Length)
            {
                RebuildBanners();
                displayCount = System.Windows.Forms.Screen.AllScreens.Length;
            }
            int currentDisplayPixelLength = 0;
            int currentDisplayPixelHeight = 0;
            int currentDisplayPixelHash = 0;
            for (int i = 0; i < System.Windows.Forms.Screen.AllScreens.Length; i++)
            {
                currentDisplayPixelLength += System.Windows.Forms.Screen.AllScreens[i].Bounds.Width;
                currentDisplayPixelHeight += System.Windows.Forms.Screen.AllScreens[i].Bounds.Height;
                currentDisplayPixelHash += System.Windows.Forms.Screen.AllScreens[i].Bounds.GetHashCode();
            }
            if (displayPixelLength != currentDisplayPixelLength)
            {
                RebuildBanners();
                displayPixelLength = currentDisplayPixelLength;
            }
            if (displayPixelHeight != currentDisplayPixelHeight)
            {
                RebuildBanners();
                displayPixelHeight = currentDisplayPixelHeight;
            }
            if (displayPixelHash != currentDisplayPixelHash)
            {
                RebuildBanners();
                displayPixelHash = currentDisplayPixelHash;
            }
            if (oldBannerColor != bannerColor)
            {
                RebuildBanners();
                oldBannerColor = bannerColor;
            }
            if (oldBannerText != bannerText)
            {
                RebuildBanners();
                oldBannerText = bannerText;
            }
        }
    }
}
