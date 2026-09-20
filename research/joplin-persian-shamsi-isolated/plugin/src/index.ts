import joplin from 'api';

joplin.plugins.register({
  onStart: async function() {
    console.info('[Joplin Persian Shamsi] isolated plugin started');
  },
});
