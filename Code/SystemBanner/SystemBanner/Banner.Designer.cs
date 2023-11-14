//Copyright (c) 2023, Aaron Wawrzyniak. MIT License Applies.
using System;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;

namespace SystemBanner
{
    partial class Banner
    {
        //make my form click-through
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.Style &= (~0x00C00000); // WS_CAPTION
                cp.Style &= (~0x00800000); // WS_BORDER
                cp.ExStyle = 0x00000080 | 0x00000008; // WS_EX_TOOLWINDOW | WS_EX_TOPMOST
                cp.ExStyle |= 0x80000 /* WS_EX_LAYERED */ | 0x20 /* WS_EX_TRANSPARENT */ | 0x80/* WS_EX_TOOLWINDOW */;
                return cp;
            }
        }

        //building a rectangle for multiple Windows USER32 API Calls

        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)] 
        private struct RECT
        {
            public int left;
            public int top;
            public int right;
            public int bottom;
        }

        //Setup for checking if any apps are fullscreen as per https://stackoverflow.com/questions/3743956/is-there-a-way-to-check-to-see-if-another-program-is-running-full-screen
        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern bool GetWindowRect(System.Runtime.InteropServices.HandleRef hWnd, [System.Runtime.InteropServices.In, System.Runtime.InteropServices.Out] ref RECT rect);

        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern System.IntPtr GetForegroundWindow();
        //make labels
        private System.Windows.Forms.Label classificationLabel;
        private System.Windows.Forms.Label leftLabel;
        private System.Windows.Forms.Label rightLabel;

        #region SystemBanner

        private void BuildBanner(int bannerScreen, bool bannerPosition)
        {   int bannerWidth = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Width; //be as wide as the screen it's on
            int bannerHeight;
            if (System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Height < 1441) //gross magic numbers that will be fixed ASAP
            {
                bannerHeight = 17;
            }
            else
            {
                bannerHeight = 24;
            }
            // 
            // Banner
            // 
            this.ClientSize = new System.Drawing.Size(bannerWidth, bannerHeight); //set the size from the above pair of INTs
            this.ControlBox = false; //no controls
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None; //no border
            this.MaximizeBox = false; //no controls
            this.MinimizeBox = false; //no controls
            this.Name = "SystemBanner"; 
            this.ShowIcon = false; //no controls
            this.Left = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.X; //appear at the left of the screen
            this.Top = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Y; //appear at the top of the screen
            if (bannerPosition == Program.bannerBottom)
            {
                this.Top = System.Windows.Forms.Screen.AllScreens[bannerScreen].WorkingArea.Bottom - bannerHeight; //appear at the bottom of the screen
            }
            this.Opacity = 0.99; //magic number, balance of readability between the banner text and lower window controls
            this.BackColor = System.Drawing.Color.Magenta;
            this.TransparencyKey = System.Drawing.Color.Magenta;
            this.Text = "SystemBanner"; 
            this.ShowInTaskbar = false; //look ma, no controls
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.BackColor = System.Drawing.Color.FromArgb(255, Program.bannerColor[0], Program.bannerColor[1], Program.bannerColor[2]); //set the background colors to the values the function arguments specify
            this.ForeColor = System.Drawing.Color.FromArgb(255, Program.bannerColor[3], Program.bannerColor[4], Program.bannerColor[5]); //set the foreground colors to the values the function arguments specify
            //
            //Labels
            //
            this.classificationLabel = new System.Windows.Forms.Label(); //create the label
            this.classificationLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter; //draw the text centered within the banner/label
            this.classificationLabel.Size = new System.Drawing.Size(bannerWidth/2, bannerHeight); //make the label the same size as the banner itself
            this.classificationLabel.Text = Program.bannerText; //set the text to the value the function argument specifies
            this.classificationLabel.Font = new System.Drawing.Font("Arial", bannerHeight-2, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Pixel); //set the label font to bold
            this.classificationLabel.Top = 0; //appear at the top of the banner
            this.classificationLabel.Left = (bannerWidth / 4); //appear at the left of the banner
            this.Controls.Add(this.classificationLabel); //draw the label

            if ( Program.debug == true)
            {
                this.leftLabel = new System.Windows.Forms.Label(); //create the label
                this.leftLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter; //draw the text centered within the banner/label
                this.leftLabel.Size = new System.Drawing.Size(120, bannerHeight); //make the label the same size as the banner itself
                this.leftLabel.Text = "SCREEN: " + bannerScreen; //set the text to the value the function argument specifies
                this.leftLabel.Font = new System.Drawing.Font("Arial", bannerHeight - 2, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Pixel); //set the label font to bold
                this.leftLabel.Top = 0; //appear at the top of the banner
                this.leftLabel.Left = 0; //appear at the left of the banner
                this.leftLabel.BackColor = System.Drawing.Color.Black;
                this.Controls.Add(this.leftLabel); //draw the label
            }
            if (Program.debug == true)
            {
                this.rightLabel = new System.Windows.Forms.Label(); //create the label
                this.rightLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter; //draw the text centered within the banner/label
                this.rightLabel.Size = new System.Drawing.Size(120, bannerHeight); //make the label the same size as the banner itself
                this.rightLabel.Text = "DEBUG: " + Program.debug; //set the text to the value the function argument specifies
                this.rightLabel.Font = new System.Drawing.Font("Arial", bannerHeight - 2, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Pixel); //set the label font to bold
                this.rightLabel.Top = 0; //appear at the top of the banner
                this.rightLabel.Left = bannerWidth - this.rightLabel.Width; //appear at the left of the banner
                this.rightLabel.BackColor = System.Drawing.Color.Black;
                this.Controls.Add(this.rightLabel); //draw the label
            }

            eventLogMessage += ("BANNER " + bannerScreen + " DISPLAY COORDINATES?" + System.Environment.NewLine);
            eventLogMessage += (this.Left + "L," + this.Top + "T," + this.Right + "R," + this.Bottom + "B" + System.Environment.NewLine);
            Program.LogEventString(eventLogMessage);

            RefreshBannerTimer();

            bool MouseOver(Form form) //if the mouse is hovering over the Banner then return true
            {
                if (bannerScreen < System.Windows.Forms.Screen.AllScreens.Length)
                {
                    if ((Cursor.Position.X < form.Right && Cursor.Position.X >= form.Left))
                    {
                        if (Cursor.Position.Y < form.Bottom && Cursor.Position.Y >= form.Top)
                        {
                            return true;

                        }
                    }
                    return false;
                }
                this.Close();
                return false;
            }
            bool IsForegroundFullScreen() //if any app is fullscreen and it clips the top left of the screen the banner is on, return true
            {

                RECT rect = new RECT();
                System.IntPtr hWnd = (System.IntPtr)GetForegroundWindow();


                GetWindowRect(new System.Runtime.InteropServices.HandleRef(null, hWnd), ref rect);

                if ((bannerScreen) < System.Windows.Forms.Screen.AllScreens.Length)
                {
                    if (System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Width == (rect.right - rect.left) && System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Height == (rect.bottom - rect.top))
                    {
                        if (rect.left == System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.X)
                        {
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    this.Close();
                    return false;
                }

            }

            void RefreshBannerTimer() //run every 0.05 seconds to detect if a mouse hover or a fullscreen app should change opacity, and if so, do it. Else, set opacity back to normal.
            {
                Timer bannerTimer = new Timer();
                bannerTimer.Interval = (50); // 0.05 sec
                bannerTimer.Tick += new System.EventHandler(RefreshBanner);
                bannerTimer.Start();
            }
            void RefreshBanner(object sender, System.EventArgs e)
            {
                if (MouseOver(this))
                {
                    this.Opacity = 0.3;
                }
                else if (IsForegroundFullScreen())
                {
                    this.Opacity = 0.3;
                    if (bannerPosition)
                    {
                        this.Top = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Bottom - bannerHeight;
                    }
                }
                else
                {
                    this.Opacity = 0.99;
                    if (bannerPosition)
                    {
                        this.Top = System.Windows.Forms.Screen.AllScreens[bannerScreen].WorkingArea.Bottom;
                    }
                }
            }

        }

        #endregion

        #region APPBAR
        private string eventLogMessage;
        //courtesy of https://www.codeproject.com/Articles/6741/AppBar-using-C


        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
        private struct APPBARDATA //creates the struct that contains the data AppBarMessages need to function
        {
            public int cbSize; //specifies the size in bytes of the APPBARDATA struct
            public System.IntPtr hWnd; //specifies the pointer of the AppBar
            public int uCallbackMessage;
            public int uEdge; //specifies which edge of the screen the AppBar lives on. In this app, ABE_TOP (1) is always used. 
            public RECT rc; //specifies the bounds of the screen that the AppBar is assigned to
            public System.IntPtr lParam;
        }

        enum ABMsg : int //conversion of the human readable ABM types (NEW, REMOVE, QUERYPOS, etc.) to their integer values that the AppBarMessages actually use.
        {
            ABM_NEW = 0, //creates the appbar and sets a pointer
            ABM_REMOVE = 1,
            ABM_QUERYPOS = 2,
            ABM_SETPOS = 3,
            ABM_GETSTATE = 4,
            ABM_GETTASKBARPOS = 5,
            ABM_ACTIVATE = 6,
            ABM_GETAUTOHIDEBAR = 7,
            ABM_SETAUTOHIDEBAR = 8,
            ABM_WINDOWPOSCHANGED = 9,
            ABM_SETSTATE = 10,
            ABM_GETAUTOHIDEBAREX = 11, //get the pointer of the AutoHideAppBarEx on the specified screen and edge
            ABM_SETAUTOHIDEBAREX = 12 //what we use to set an AppBar that shows up on a specific screen.
        }

        enum ABNotify : int //conversion of the human readable ABN types to their integer values that the AppBarMessages actually use.
        {
            ABN_STATECHANGE = 0,
            ABN_POSCHANGED = 1,
            ABN_FULLSCREENAPP = 2,
            ABN_WINDOWARRANGE = 3
        }

        enum ABEdge : int //specifies which edge of the screen the AppBar lives on. In this app, ABE_TOP (1) is always used. 
        {
            ABE_LEFT = 0,
            ABE_TOP = 1,
            ABE_RIGHT = 2,
            ABE_BOTTOM = 3
        }

        //pull in USER32 and SHELL32 to interact with the system and build the AppBars 

        [System.Runtime.InteropServices.DllImport("SHELL32", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
        static extern uint SHAppBarMessage(int dwMessage, ref APPBARDATA pData);
        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern int RegisterWindowMessage(string msg);
        private int uCallBack;
        private void BuildAppBar(int appBarScreen, bool appBarPosition) //build an AppBar and set the position and screen of the AppBar
        {
            int appBarHeight;
            if (System.Windows.Forms.Screen.AllScreens[appBarScreen].Bounds.Height < 1441) //Gross magic numbers for scaling. This will be fixed ASAP.
            {
                appBarHeight = 17;
            }
            else
            {
                appBarHeight = 24;
            }
            APPBARDATA abd = new APPBARDATA();//new instance of the APPBARDATA struct
            abd.cbSize = System.Runtime.InteropServices.Marshal.SizeOf(abd);  //grab the size of the abd instance
            abd.hWnd = this.Handle; //specify the pointer of the abd as the pointer of this AppBar instance
            abd.uEdge = (int)ABEdge.ABE_TOP; //set the appbar screen edge binding to top
            if (appBarPosition == Program.bannerBottom) //if appbar is for a bottom banner...
            {
                abd.uEdge = (int)ABEdge.ABE_BOTTOM; //set the appbar screen edge binding to bottom
            }
            abd.lParam = (IntPtr)1; //set lParam to true to specify the autohidebarex call to register the appbar, not unregister it
            uCallBack = RegisterWindowMessage("AppBarMessage");
            SHAppBarMessage((int)ABMsg.ABM_NEW, ref abd); //create the new AppBar using the above data
            //
            //dimensions of the AppBar on the screen that the AppBar will run on
            //
            abd.rc.left = System.Windows.Forms.Screen.AllScreens[appBarScreen].Bounds.X; //left of the screen X coordinate
            abd.rc.top = System.Windows.Forms.Screen.AllScreens[appBarScreen].Bounds.Y; //top of the screen Y coordinate
            abd.rc.right = abd.rc.left + System.Windows.Forms.Screen.AllScreens[appBarScreen].Bounds.Width; //top right of the screen X coordinate
            abd.rc.bottom = abd.rc.top + appBarHeight; //appBarHeight is the number of pixels down from the top of the screen
            if (appBarPosition == Program.bannerBottom) //if appbar is for a bottom banner...
            {
                abd.rc.bottom = System.Windows.Forms.Screen.AllScreens[appBarScreen].WorkingArea.Bottom; //appBar bottom is the bottom of the working area (minus the taskbar, of course)
                abd.rc.top = System.Windows.Forms.Screen.AllScreens[appBarScreen].WorkingArea.Bottom - appBarHeight; //appBar top is the bottom of the working area less the height of the appbar.
            }
            eventLogMessage = ("APPBAR " + appBarScreen + " COORDINATES?" + System.Environment.NewLine);
            eventLogMessage += (abd.rc.left + "L," + abd.rc.top + "T," + abd.rc.right + "R," + abd.rc.bottom + "B" + System.Environment.NewLine);
            eventLogMessage += ("APPBAR " + appBarScreen + " POSITIONED?" + System.Environment.NewLine);
            eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETPOS, ref abd) + System.Environment.NewLine); //set the position of the appbar on the screen and write a 1 for true in the console if the positioning succeeded
            eventLogMessage += ("APPBAR " + appBarScreen + " REGISTERED?" + System.Environment.NewLine);
            //eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETAUTOHIDEBAREX, ref abd) + System.Environment.NewLine); //register the autohidebarex and write a 1 for true if the registration succeeded
            System.IntPtr hWnd = (System.IntPtr)SHAppBarMessage((int)ABMsg.ABM_GETAUTOHIDEBAREX, ref abd); //grab ptr of the running appbar to ensure it exists
            eventLogMessage += ("APPBAR " + appBarScreen + " WITH PTR " + abd.hWnd + " RUNNING." + System.Environment.NewLine);
            Program.LogEventString(eventLogMessage);
        }
        private void KillAppBar() //kill an AppBar at the position and screen of the AppBar
        {
            APPBARDATA abd = new APPBARDATA();//new instance of the APPBARDATA struct
            abd.cbSize = System.Runtime.InteropServices.Marshal.SizeOf(abd);  //grab the size of the abd instance
            abd.hWnd = this.Handle; //specify the pointer of the abd as the pointer of this AppBar instance
            abd.uEdge = (int)ABEdge.ABE_TOP; //set the appbar screen edge binding to top
            abd.lParam = (IntPtr)0; //set lParam to false to specify the autohidebarex call to unregister the appbar, not register it
            uCallBack = RegisterWindowMessage("AppBarMessage");
            abd.rc.left = System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.X; //top left of the screen X coordinate
            abd.rc.top = System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Y; //top left of the screen Y coordinate
            abd.rc.right = abd.rc.left + System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Width; //top right of the screen X coordinate
            abd.rc.bottom = abd.rc.top + System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Height; //bottom left of the screen Y coordinate

            eventLogMessage = ("REMOVING APPBAR WITH PTR " + abd.hWnd + "." + System.Environment.NewLine);
            eventLogMessage += ("QUERYING APPBAR POS ");
            eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_GETAUTOHIDEBAREX, ref abd) + System.Environment.NewLine); //get the details of the appbar on the screen and write a 1 for true in the console if the positioning succeeded
            eventLogMessage += ("APPBAR " + " COORDINATES?" + System.Environment.NewLine);
            eventLogMessage += (abd.rc.left + "L," + abd.rc.top + "T," + abd.rc.right + "R," + abd.rc.bottom + "B" + System.Environment.NewLine);
            eventLogMessage += ("UNREGISTERING APPBAR ");
            eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETAUTOHIDEBAREX, ref abd) + System.Environment.NewLine); //unregister the autohidebarex and write a 1 for true if the action succeeded
            eventLogMessage += ("REMOVING APPBAR ");
            eventLogMessage += SHAppBarMessage((int)ABMsg.ABM_REMOVE, ref abd); //remove the AppBar using the above data and writes a 1 for true if the removal succeeded
            Program.LogEventString(eventLogMessage);

            if (Program.bannerTopAndBottom)
            {
                APPBARDATA abdBottom = new APPBARDATA();//new instance of the APPBARDATA struct
                abdBottom.cbSize = System.Runtime.InteropServices.Marshal.SizeOf(abdBottom);  //grab the size of the abdBottom instance
                abdBottom.hWnd = this.Handle; //specify the pointer of the abdBottom as the pointer of this AppBar instance
                abdBottom.uEdge = (int)ABEdge.ABE_TOP; //set the appbar screen edge binding to top
                abdBottom.lParam = (IntPtr)0; //set lParam to false to specify the autohidebarex call to unregister the appbar, not register it
                uCallBack = RegisterWindowMessage("AppBarMessage");
                abdBottom.rc.left = System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.X; //top left of the screen X coordinate
                abdBottom.rc.top = System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Y; //top left of the screen Y coordinate
                abdBottom.rc.right = abdBottom.rc.left + System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Width; //top right of the screen X coordinate
                abdBottom.rc.bottom = abdBottom.rc.top + System.Windows.Forms.Screen.FromHandle(this.Handle).Bounds.Height; //bottom left of the screen Y coordinate

                eventLogMessage = ("REMOVING APPBAR WITH PTR " + abdBottom.hWnd + "." + System.Environment.NewLine);
                eventLogMessage += ("QUERYING APPBAR POS ");
                eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_GETAUTOHIDEBAREX, ref abdBottom) + System.Environment.NewLine); //get the details of the appbar on the screen and write a 1 for true in the console if the positioning succeeded
                eventLogMessage += ("APPBAR " + " COORDINATES?" + System.Environment.NewLine);
                eventLogMessage += (abdBottom.rc.left + "L," + abdBottom.rc.top + "T," + abdBottom.rc.right + "R," + abdBottom.rc.bottom + "B" + System.Environment.NewLine);
                eventLogMessage += ("UNREGISTERING APPBAR ");
                eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETAUTOHIDEBAREX, ref abdBottom) + System.Environment.NewLine); //unregister the autohidebarex and write a 1 for true if the action succeeded
                eventLogMessage += ("REMOVING APPBAR ");
                eventLogMessage += SHAppBarMessage((int)ABMsg.ABM_REMOVE, ref abdBottom); //remove the AppBar using the above data and writes a 1 for true if the removal succeeded
                Program.LogEventString(eventLogMessage);
            }
        }
        #endregion

    }
}

