using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Tridion.ContentManager.ContentManagement;
using Tridion.ContentManager.Extensibility;
using Tridion.ContentManager.Extensibility.Events;

namespace Example
{
    [TcmExtension("ComponentSaveImageSizeChecker")]
    public class ImageSizeChecker : TcmExtension
    {
        public ImageSizeChecker() 
        {
            EventSystem.Subscribe<Component, SaveEventArgs>( ComponentSaveInitiatedHandler, EventPhases.Initiated);
        }

        private void ComponentSaveInitiatedHandler(Component component, SaveEventArgs args, EventPhases phase)
        {
            string[] interestingMimeTypes = new string[] { "image/jpeg", "image/gif", "image/png", "image/x-bmp" };
            if (interestingMimeTypes.Contains(component.BinaryContent.MultimediaType.MimeType))
            {
                string title = component.Schema.Title;
                Regex re = new Regex(@"
                        \[\s*           # first '[' and some whitespace
                        (?<width>\d*)   # um.. the width
                        \s*x\s*         # the 'x'
                        (?<height>\d*)  # height
                        \s*\]           # finish off with another squaredy-bracket
                    ", RegexOptions.IgnorePatternWhitespace);
                Match match = re.Match(title);
                if (!match.Success)
                {
                    return;
                }

                int expectedWidth = int.Parse(match.Groups["width"].Value);
                int expectedHeight = int.Parse(match.Groups["height"].Value);

                if (component.BinaryContent != null)
                {
                    using (MemoryStream mem = new MemoryStream())
                    {
                        component.BinaryContent.WriteToStream(mem);
                        Bitmap bitmap = null;
                        try
                        {
                            bitmap = new Bitmap(mem);
                            if (expectedWidth != bitmap.Width || expectedHeight != bitmap.Height)
                            {
                                throw new WrongSizeImageException(string.Format("You can only save a MM component of type {0} if it is {1}x{2}px. This image is {3}x{4}px"
                                    , title, expectedWidth, expectedHeight, bitmap.Width, bitmap.Height));
                            }
                        }
                        catch (System.ArgumentException)
                        {
                            if (mem.Length > 1)
                            {
                                throw new WrongSizeImageException("Unable to process this image, probably because it is too large, or not in a recognised image format.");
                            }
                            else throw;
                        }
                        finally
                        {
                            if (bitmap != null) { bitmap.Dispose(); }
                        }
                    }
                }
            }
        }

        [Serializable]
        public class WrongSizeImageException : Exception
        {
            public WrongSizeImageException() { }
            public WrongSizeImageException(string message) : base(message) { }
            public WrongSizeImageException(string message, Exception inner) : base(message, inner) { }
            protected WrongSizeImageException(
              System.Runtime.Serialization.SerializationInfo info,
              System.Runtime.Serialization.StreamingContext context)
                : base(info, context) { }
        }
    }
}
