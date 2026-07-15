<!-- Mobile Navigation --> <?php
$requestPath = parse_url($_SERVER['REQUEST_URI']?? '/', PHP_URL_PATH)?: '/';
$isBlog = ($requestPath === '/blog' || $requestPath === '/blog.php' || $requestPath === '/blog-post' || $requestPath === '/blog-post.php');
$isServices = ($requestPath === '/services' || strpos($requestPath, '/services/') === 0);
$isHome = ($requestPath === '/' || $requestPath === '/index.html');
$isAbout = ($requestPath === '/about' || $requestPath === '/about.html');
$isContact = ($requestPath === '/contact' || $requestPath === '/contact.html');
$isApply = ($requestPath === '/apply-online' || $requestPath === '/apply-online.html');?> <div class="mobile-nav"> <button class="mobile-nav-close" aria-label="Close mobile menu"> <i class="fas fa-times">
</i> </button> <ul> <li>
<a href="/"<?php echo $isHome? ' class="active" aria-current="page"': '';?>>Home</a>
</li> <li>
<a href="/about"<?php echo $isAbout? ' class="active" aria-current="page"': '';?>>About</a>
</li> <li>
<a href="/services"<?php echo $isServices? ' class="active" aria-current="page"': '';?>>Services</a>
</li> <li>
<a href="/contact"<?php echo $isContact? ' class="active" aria-current="page"': '';?>>Contact</a>
</li> <li>
<a href="/apply-online"<?php echo $isApply? ' class="active" aria-current="page"': '';?>>Apply Online</a>
</li> <li>
<a href="/blog"<?php echo $isBlog? ' class="active" aria-current="page"': '';?>>Blog</a>
</li> </ul> <a href="tel:0370648292" class="cta-button" style="margin-top: 30px; width: 100%;"> <i class="fas fa-phone">
</i> Call: 037 064 8292 </a> </div>


