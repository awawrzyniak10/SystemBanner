using System.Windows.Forms;

namespace SystemBanner
{
    public partial class Banner : Form
    {
        public Banner(int instanceScreen, int[] instanceColor, string instanceText)
        {
            BuildBanner(instanceScreen, instanceColor, instanceText);
        }
    }
}
