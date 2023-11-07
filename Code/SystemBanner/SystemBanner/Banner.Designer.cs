using System.Windows.Forms;

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

        //Setup for checking if any apps are fullscreen as per https://stackoverflow.com/questions/3743956/is-there-a-way-to-check-to-see-if-another-program-is-running-full-screen

        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)] 
        private struct RECT
        {
            public int left;
            public int top;
            public int right;
            public int bottom;
        }

        //Setup for checking if any apps are fullscreen
        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern bool GetWindowRect(System.Runtime.InteropServices.HandleRef hWnd, [System.Runtime.InteropServices.In, System.Runtime.InteropServices.Out] ref RECT rect);

        [System.Runtime.InteropServices.DllImport("USER32")]
        private static extern System.IntPtr GetForegroundWindow();


        //make the label
        private System.Windows.Forms.Label label1;

        #region SystemBanner

        private void BuildBanner(int bannerScreen, int[] bannerColor, string labelText)
        {   int bannerWidth = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Width; //be as wide as the screen it's on
            int bannerHeight;
            if (System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Height < 1441)
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
            this.Left = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.X; //appear at the top of the screen
            this.Top = System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Y; //appear at the left of the screen
            //this.TopMost = true; //appear on top of all windows
            this.Opacity = 0.99; //magic number, balance of readability between the banner text and lower window controls
            this.BackColor = System.Drawing.Color.Magenta;
            this.TransparencyKey = System.Drawing.Color.Magenta;
            this.Text = "SystemBanner"; 
            this.ShowInTaskbar = false; //look ma, no controls
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            //
            //Label
            //
            this.label1 = new System.Windows.Forms.Label(); //create the label
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter; //draw the text centered within the banner/label
            this.label1.Size = new System.Drawing.Size(bannerWidth, bannerHeight); //make the label the same size as the banner itself
            this.label1.Text = labelText; //set the text to the value the function argument specifies
            this.label1.Font = new System.Drawing.Font("Arial", bannerHeight-2, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Pixel); //set the label font to bold
            this.label1.BackColor = System.Drawing.Color.FromArgb(255, bannerColor[0], bannerColor[1], bannerColor[2]); //set the background colors to the values the function arguments specify
            this.label1.ForeColor = System.Drawing.Color.FromArgb(255, bannerColor[3], bannerColor[4], bannerColor[5]); //set the foreground colors to the values the function arguments specify
            this.label1.Top = 0; //appear at the top of the banner
            this.label1.Left = 0; //appear at the left of the banner
            this.Controls.Add(this.label1); //draw the label
            RefreshOpacityTimer();

            bool MouseOver(Form form) //if the mouse is hovering over the Banner then return true
            {
                if (bannerScreen < System.Windows.Forms.Screen.AllScreens.Length)
                {
                    if ((Cursor.Position.X < form.Width + System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.X && Cursor.Position.X >= System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.X))
                    {

                        if (Cursor.Position.Y < System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Y + form.Height && Cursor.Position.Y >= System.Windows.Forms.Screen.AllScreens[bannerScreen].Bounds.Y)
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

            void RefreshOpacityTimer() //run every 0.02 seconds to detect if a mouse hover or a fullscreen app should change opacity, and if so, do it. Else, set opacity back to normal.
            {
                Timer bannerTimer = new Timer();
                bannerTimer.Interval = (20); // 0.02 sec
                bannerTimer.Tick += new System.EventHandler(RefreshOpacity);
                bannerTimer.Start();
            }
            void RefreshOpacity(object sender, System.EventArgs e)
            {
                if (MouseOver(this))
                {
                    this.Opacity = 0.3;
                }
                else if (IsForegroundFullScreen())
                {
                    this.Opacity = 0.3;
                }
                else
                {
                    this.Opacity = 0.99;
                }
            }

        }

        #endregion
    }
}

