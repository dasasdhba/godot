use godot::classes::ResourceLoader;
use godot::prelude::*;

use super::ResourceFormatLoaderFluent;

/// Singleton for handling Fluent Translation. For internal use only.
#[derive(GodotClass)]
#[class(tool, base=Object, init)]
pub struct FluentI18nSingleton {
    loader: Option<Gd<ResourceFormatLoaderFluent>>,
}

impl FluentI18nSingleton {
    pub(crate) const SINGLETON_NAME: &'static str = "FluentI18nSingleton";

    pub(crate) fn register(&mut self) {
        let loader = ResourceFormatLoaderFluent::new_gd();
        ResourceLoader::singleton().add_resource_format_loader(&loader);
        self.loader = Some(loader);
    }

    pub(crate) fn unregister(&self) {
        if let Some(loader) = &self.loader {
            ResourceLoader::singleton().remove_resource_format_loader(loader);
        }
    }
}
