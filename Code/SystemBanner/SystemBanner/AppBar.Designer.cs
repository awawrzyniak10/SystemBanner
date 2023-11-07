using System;
using System.Windows.Forms;
namespace SystemBanner
{
    partial class AppBar
    {
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.Style &= (~0x00C00000); // WS_CAPTION
                cp.Style &= (~0x00800000); // WS_BORDER
                //cp.ExStyle = 0x00000080 | 0x00000008; // WS_EX_TOOLWINDOW | WS_EX_TOPMOST
                cp.ExStyle |= 0x80000 /* WS_EX_LAYERED */ | 0x20 /* WS_EX_TRANSPARENT */ | 0x80/* WS_EX_TOOLWINDOW */;
                return cp;
            }
        }

        #region APPBAR
        private string eventLogMessage;
        //courtesy of https://www.codeproject.com/Articles/6741/AppBar-using-C

        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
        private struct RECT //specifies the bounds of the screen that the AppBar is assigned to
        {
            public int left;
            public int top;
            public int right;
            public int bottom;
        }

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
            ABN_POSCHANGED,
            ABN_FULLSCREENAPP,
            ABN_WINDOWARRANGE
        }

        enum ABEdge : int //specifies which edge of the screen the AppBar lives on. In this app, ABE_TOP (1) is always used. 
        {
            ABE_LEFT = 0,
            ABE_TOP,
            ABE_RIGHT,
            ABE_BOTTOM
        }

        //pull in USER32 and SHELL32 to interact with the system and build the AppBars 

        [System.Runtime.InteropServices.DllImport("SHELL32", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
        static extern uint SHAppBarMessage(int dwMessage, ref APPBARDATA pData);
        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern int RegisterWindowMessage(string msg);
        private int uCallBack;
        private void BuildAppBar(int instanceScreen) //build an AppBar and set the position and screen of the AppBar
        {
            int appBarHeight;
            if (System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Height < 1441)
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
            abd.lParam = (IntPtr)1; //set lParam to true to specify the autohidebarex call to register the appbar, not unregister it
            uCallBack = RegisterWindowMessage("AppBarMessage");
            SHAppBarMessage((int)ABMsg.ABM_NEW, ref abd); //create the new AppBar using the above data
            //
            //dimensions of the AppBar on the screen that the AppBar will run on
            //
            abd.rc.left = System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.X; //top left of the screen X coordinate
            abd.rc.top = System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Y; //top left of the screen Y coordinate
            abd.rc.right = abd.rc.left + System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Width; //top right of the screen X coordinate
            abd.rc.bottom = abd.rc.top + appBarHeight; //appBarHeight is the number of pixels down from the top of the screen
            eventLogMessage += ("APPBAR " + instanceScreen + " COORDINATES?" + System.Environment.NewLine);
            eventLogMessage += (abd.rc.left + "L," + abd.rc.top + "T," + abd.rc.right + "R," + abd.rc.bottom + "B" + System.Environment.NewLine);
            eventLogMessage += ("APPBAR " + instanceScreen + " POSITIONED?" + System.Environment.NewLine);
            eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETPOS, ref abd) + System.Environment.NewLine); //set the position of the appbar on the screen and write a 1 for true in the console if the positioning succeeded
            //
            //dimensions of the screen that the AppBar will run on
            //
            abd.rc.left = System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.X; //top left of the screen X coordinate
            abd.rc.top = System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Y; //top left of the screen Y coordinate
            abd.rc.right = abd.rc.left + System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Width; //top right of the screen X coordinate
            abd.rc.bottom = abd.rc.top + System.Windows.Forms.Screen.AllScreens[instanceScreen].Bounds.Height; //bottom left of the screen Y coordinate
            eventLogMessage += ("APPBAR " + instanceScreen + " DISPLAY COORDINATES?" + System.Environment.NewLine);
            eventLogMessage += (abd.rc.left + "L," + abd.rc.top + "T," + abd.rc.right + "R," + abd.rc.bottom + "B" + System.Environment.NewLine);
            eventLogMessage += ("APPBAR " + instanceScreen + " REGISTERED?" + System.Environment.NewLine);
            eventLogMessage += (SHAppBarMessage((int)ABMsg.ABM_SETAUTOHIDEBAREX, ref abd) + System.Environment.NewLine); //register the autohidebarex and write a 1 for true in the console if the registration succeeded
            System.IntPtr hWnd = (System.IntPtr)SHAppBarMessage((int)ABMsg.ABM_GETAUTOHIDEBAREX, ref abd); //grab ptr of the running appbar to ensure it exists
            eventLogMessage += ("APPBAR " + instanceScreen + " WITH PTR " + abd.hWnd + " RUNNING." + System.Environment.NewLine);
            using (System.Diagnostics.EventLog eventLog = new System.Diagnostics.EventLog("Application"))
            {
                eventLog.Source = "Application";
                eventLog.WriteEntry(eventLogMessage, System.Diagnostics.EventLogEntryType.Information, 69, 1);
            }
        }
        #endregion
    }

}