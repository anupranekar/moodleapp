// (C) Copyright 2015 Moodle Pty Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { Injectable } from '@angular/core';
import { CoreCourse } from '@features/course/services/course';
import { CoreNavigator } from '@services/navigator';
import { CoreSitesReadingStrategy } from '@services/sites';
import { makeSingleton, Translate } from '@singletons';
import { Md5 } from 'ts-md5';
import { AddonModWiki } from '../wiki';
import { ADDON_MOD_WIKI_MODNAME, ADDON_MOD_WIKI_PAGE_NAME } from '../../constants';
import { AddonModWikiPageOrMapLinkHandlerService } from '@addons/mod/wiki/services/handlers/page-or-map-link';
import { CoreLoadings } from '@services/overlays/loadings';
import { CoreAlerts } from '@services/overlays/alerts';

/**
 * Handler to treat links to a wiki page or the wiki map.
 */
@Injectable({ providedIn: 'root' })
export class AddonModWikiPageOrMapLinkHandlerLazyService extends AddonModWikiPageOrMapLinkHandlerService {

    /**
     * @inheritdoc
     */
    async handleAction(url: string, siteId: string, params: Record<string, string>): Promise<void> {
        const modal = await CoreLoadings.show();
        const pageId = parseInt(params.pageid, 10);
        const action = url.indexOf('mod/wiki/map.php') != -1 ? 'map' : 'page';

        try {
            // Get the page data to obtain wikiId, subwikiId, etc.
            const page = await AddonModWiki.getPageContents(pageId, { siteId });

            const module = await CoreCourse.getModuleBasicInfoByInstance(
                page.wikiid,
                ADDON_MOD_WIKI_MODNAME,
                { siteId, readingStrategy: CoreSitesReadingStrategy.PREFER_CACHE },
            );

            const hash = Md5.hashAsciiStr(JSON.stringify({
                pageId: page.id,
                pageTitle: page.title,
                subwikiId: page.subwikiid,
                action: action,
                timestamp: Date.now(),
            }));

            await CoreNavigator.navigateToSitePath(
                `${ADDON_MOD_WIKI_PAGE_NAME}/${module.course}/${module.id}/page/${hash}`,
                {
                    params: {
                        module,
                        pageId: page.id,
                        pageTitle: page.title,
                        subwikiId: page.subwikiid,
                        action: action,
                    },
                    siteId,
                },
            );
        } catch (error) {
            CoreAlerts.showError(error, { default: Translate.instant('addon.mod_wiki.errorloadingpage') });
        } finally {
            modal.dismiss();
        }
    }

    /**
     * @inheritdoc
     */
    async isEnabled(siteId: string, url: string, params: Record<string, string>): Promise<boolean> {
        const isMap = url.indexOf('mod/wiki/map.php') != -1;

        if (params.id && !isMap) {
            // ID param is more prioritary than pageid in index page, it's a index URL.
            return false;
        } else if (isMap && params.option !== undefined && params.option != '5') {
            // Map link but the option isn't "Page list", not supported.
            return false;
        }

        return true;
    }

}

export const AddonModWikiPageOrMapLinkHandler = makeSingleton(AddonModWikiPageOrMapLinkHandlerLazyService);
