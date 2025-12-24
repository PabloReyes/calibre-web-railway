# Calibre-Web on Railway

A Railway deployment template for [Calibre-Web](https://github.com/janeczku/calibre-web), a web application for managing and reading eBooks from your Calibre library.

This template uses the official [linuxserver/calibre-web](https://hub.docker.com/r/linuxserver/calibre-web) Docker image and automatically initializes an empty Calibre database to prevent the common "DB location is not valid" error.

## Features

- 🚀 One-click deployment to Railway
- 📚 Automatic empty Calibre database initialization
- 🐳 Uses official linuxserver/calibre-web Docker image
- 🔒 Persistent storage via Railway volumes
- ⚙️ Pre-configured for Railway environment

## Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/calibre-web)

## Manual Deployment

1. Fork this repository
2. Create a new project on Railway
3. Connect your forked repository
4. Add a volume:
   - Mount path: `/books`
   - This will store your Calibre library and metadata
5. Add another volume:
   - Mount path: `/config`
   - This will store Calibre-Web configuration
6. Set environment variables (optional):
   - `PUID=1000` (User ID for file permissions)
   - `PGID=1000` (Group ID for file permissions)
   - `TZ=America/New_York` (Your timezone)
7. Deploy!

## Initial Setup

After deployment:

1. Access your Calibre-Web instance at the Railway-provided URL
2. Default credentials:
   - Username: `admin`
   - Password: `admin123`
3. **Important:** Change the default password immediately after first login
4. The database location is pre-configured to `/books` (you don't need to change this)
5. Configure additional settings in the Admin panel

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for file permissions | `1000` |
| `PGID` | Group ID for file permissions | `1000` |
| `TZ` | Timezone for the container | `Etc/UTC` |
| `DOCKER_MODS` | Optional: Add `linuxserver/mods:universal-calibre` for eBook conversion | - |
| `OAUTHLIB_RELAX_TOKEN_SCOPE` | Optional: Set to `1` for Google OAuth compatibility | - |

### Volumes

- `/books` - Calibre library location (contains metadata.db and eBooks)
- `/config` - Calibre-Web application configuration and database

## Adding Books

To add books to your library:

1. Upload books through the Calibre-Web interface (Admin > Upload)
2. Or use Calibre Desktop application to manage your library and sync the files to your `/books` volume

## Features of Calibre-Web

- Web-based eBook library management
- OPDS feed for reading apps
- Book metadata editing and management
- User management with different access levels
- eBook format conversion (with optional DOCKER_MODS)
- Send books to Kindle
- Advanced search and filtering
- Custom columns and tags

## Troubleshooting

### "DB location is not valid" Error

This template automatically creates an empty metadata.db file, so you shouldn't see this error. If you do:

1. Check that the `/books` volume is properly mounted
2. Verify file permissions are correct
3. Check the logs for initialization script output

### Port Configuration

Railway automatically exposes port 8083 (Calibre-Web's default port). You don't need to configure this manually.

### Persistent Storage

Make sure you've added the required volumes (`/books` and `/config`) in Railway's volume settings. Without these, your data will be lost on redeployment.

## Resources

- [Calibre-Web GitHub](https://github.com/janeczku/calibre-web)
- [LinuxServer Calibre-Web Documentation](https://docs.linuxserver.io/images/docker-calibre-web/)
- [Railway Documentation](https://docs.railway.com/)

## License

This template is MIT licensed. Calibre-Web and its dependencies may have different licenses.
