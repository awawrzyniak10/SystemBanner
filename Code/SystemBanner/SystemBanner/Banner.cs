//Copyright (c) 2023, Aaron Wawrzyniak. MIT License Applies.
using System;
using System.Windows.Forms;

namespace SystemBanner
{
    public partial class Banner : Form
    {
        public Banner(int instanceScreen, bool instancePosition)
        {
            BuildBanner(instanceScreen, instancePosition);
            BuildAppBar(instanceScreen, instancePosition);

        }
        protected override void OnFormClosed(FormClosedEventArgs e)
        {
            KillAppBar();
            base.OnFormClosed(e);
        }
    }
}
